import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class DummyDataStreamer {
  final int channels = 14;
  final int sampleRate = 128; // Hz
  final int bufferSize = 256; // 2 seconds of data
  final int stepSize = 128; // 1 second overlap

  List<List<double>> _fullData = [];
  int _currentIndex = 0;
  Timer? _timer;

  // Stream controller to emit 2-second buffers every 1 second
  final _controller = StreamController<List<List<double>>>.broadcast();
  Stream<List<List<double>>> get eegStream => _controller.stream;

  /// Loads dummy data from a text file in assets (e.g., exported from STEW dataset)
  /// Expected format: 14 columns of floats separated by space/tab per line.
  Future<void> loadDataFromAsset(String assetPath) async {
    try {
      final String fileContent = await rootBundle.loadString(assetPath);
      final List<String> lines = fileContent.split('\n');

      _fullData = List.generate(channels, (_) => []);

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        var values = line.trim().split(RegExp(r'\s+'));
        if (values.length >= channels) {
          for (int i = 0; i < channels; i++) {
            _fullData[i].add(double.tryParse(values[i]) ?? 0.0);
          }
        }
      }
      print("DummyDataStreamer: Loaded ${_fullData[0].length} samples per channel.");
    } catch (e) {
      print("DummyDataStreamer Error: Could not load asset data - $e");
    }
  }

  /// Starts streaming data at 1 buffer per second (real-time simulation)
  void startStreaming() {
    if (_fullData.isEmpty || _fullData[0].length < bufferSize) {
      print("DummyDataStreamer: Not enough data loaded.");
      return;
    }

    _currentIndex = 0;
    
    // Fire every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentIndex + bufferSize > _fullData[0].length) {
        // Loop back to the start if we reach the end
        _currentIndex = 0; 
      }

      // Extract a (14 x 256) buffer
      List<List<double>> buffer = [];
      for (int i = 0; i < channels; i++) {
        buffer.add(
          _fullData[i].sublist(_currentIndex, _currentIndex + bufferSize)
        );
      }

      // Emit to stream
      _controller.add(buffer);

      // Advance by 1 second (128 samples) to maintain 50% overlap
      _currentIndex += stepSize;
    });
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopStreaming();
    _controller.close();
  }
}
