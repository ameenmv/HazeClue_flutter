import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';
import 'inference_service.dart'; // To reuse InferenceResult class if needed, or I'll just redefine it here if I don't import. Actually I will just import it.

class OnnxLocalInferenceService {
  late OrtSession _session;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // We assume OrtEnv.instance.init() is called in main.dart
    final sessionOptions = OrtSessionOptions();
    final rawAssetFile = await rootBundle.load('assets/models/lstm_workload.onnx');
    final bytes = rawAssetFile.buffer.asUint8List();
    
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
    _isInitialized = true;
  }

  Future<InferenceResult?> getFocusPrediction(List<List<double>> windowData) async {
    if (!_isInitialized) {
      print('ONNX model not initialized');
      return null;
    }

    try {
      // The ONNX model expects a shape of [1, 256, 14]
      // windowData should be a list of 256 time steps, each containing 14 features
      
      // Flatten the data for the tensor
      List<double> flatData = [];
      for (var timeStep in windowData) {
        flatData.addAll(timeStep);
      }

      // Ensure the size is correct
      if (flatData.length != 256 * 14) {
        print('Invalid input shape. Expected 256x14, got \${windowData.length}x\${windowData.isNotEmpty ? windowData[0].length : 0}');
        return null;
      }

      // Create Float32List
      final float32Data = Float32List.fromList(flatData);
      
      // Create OrtValueTensor
      final inputOrt = OrtValueTensor.createTensorWithDataList(
        float32Data, 
        [1, 256, 14],
      );

      final runOptions = OrtRunOptions();
      final inputs = {'input': inputOrt};
      
      // Run inference
      final outputs = _session.run(runOptions, inputs);
      
      // Release input
      inputOrt.release();
      runOptions.release();

      // Output shape is [1, 2]
      final outputOrt = outputs[0];
      
      // We parse the output
      final outputValue = outputOrt?.value;
      outputOrt?.release();

      if (outputValue is List && outputValue.isNotEmpty) {
        // onnxruntime dart package typically returns nested lists based on shape. 
        // For [1, 2] shape, it might be a List<List<double>> or List<dynamic>
        final batchLogits = outputValue[0] as List;
        final logits = [
          (batchLogits[0] as num).toDouble(),
          (batchLogits[1] as num).toDouble(),
        ];
        
        // Softmax
        final maxLogit = logits.reduce((a, b) => a > b ? a : b);
        final exps = logits.map((e) => exp(e - maxLogit)).toList();
        final sumExps = exps.reduce((a, b) => a + b);
        final probs = exps.map((e) => e / sumExps).toList();

        final prediction = probs[0] > probs[1] ? 0 : 1;
        final probability = probs[prediction];

        return InferenceResult(
          prediction: prediction,
          probability: probability,
          smoothedOutput: probability,
          mode: prediction == 1 ? 'WORKLOAD' : 'SAFE',
          sqiMean: 1.0, // Assuming 1.0 since it's dummy in local infer without sqi data
          accepted: true,
        );
      }
      return null;
    } catch (e) {
      print('Exception during ONNX inference: \$e');
      return null;
    }
  }

  void dispose() {
    if (_isInitialized) {
      _session.release();
      _isInitialized = false;
    }
  }
}
