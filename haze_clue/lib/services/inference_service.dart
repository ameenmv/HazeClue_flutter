import 'dart:convert';
import 'package:http/http.dart' as http;

class InferenceResult {
  final int prediction;
  final double probability;
  final double smoothedOutput;
  final String mode;
  final double sqiMean;
  final bool accepted;

  InferenceResult({
    required this.prediction,
    required this.probability,
    required this.smoothedOutput,
    required this.mode,
    required this.sqiMean,
    required this.accepted,
  });

  factory InferenceResult.fromJson(Map<String, dynamic> json) {
    return InferenceResult(
      prediction: json['prediction'] ?? 0,
      probability: (json['probability'] ?? 0.0).toDouble(),
      smoothedOutput: (json['smoothed_output'] ?? 0.0).toDouble(),
      mode: json['mode'] ?? 'SAFE',
      sqiMean: (json['sqi_mean'] ?? 0.0).toDouble(),
      accepted: json['accepted'] ?? false,
    );
  }
}

class InferenceService {
  // Update this to your local machine IP or production server IP when deploying
  final String baseUrl = 'http://10.0.2.2:8000'; // 10.0.2.2 is the localhost alias for Android Emulator

  Future<InferenceResult?> getFocusPrediction(List<List<double>> windowData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inference'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': windowData}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return InferenceResult.fromJson(data);
      } else {
        print('Error from Inference API: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception calling Inference API: $e');
      return null;
    }
  }
}
