import 'dart:math';
import 'package:fftea/fftea.dart';

class FocusCalculator {
  static const int sampleRate = 128; // Hz
  static const int bufferSize = 256; // 2 seconds

  double _ema = 0.0;
  double _baseline = 1.0;
  double _minEi = double.maxFinite;
  double _maxEi = -double.maxFinite;
  
  bool isCalibrating = true;
  List<double> _calibrationBuffer = [];
  int _calibrationSeconds = 0;
  final int maxCalibrationSeconds = 60; // Wait 60s for baseline

  // Smoothing factor for EMA (تنعيم النتائج)
  final double smoothingFactor = 0.2;

  // Calculate PSD for a single channel buffer using Welch's method (single window for simplicity)
  List<double> calculatePsd(List<double> channelData) {
    // Apply Hann window
    final windowedData = List<double>.from(channelData);
    for (int i = 0; i < windowedData.length; i++) {
      windowedData[i] *= 0.5 * (1 - cos(2 * pi * i / (windowedData.length - 1)));
    }

    final fft = FFT(windowedData.length);
    final freqs = fft.realFft(windowedData);
    
    // Calculate power (magnitude squared)
    List<double> psd = [];
    for (int i = 0; i < freqs.length; i++) {
      final mag = freqs[i].magnitude();
      psd.add((mag * mag) / windowedData.length); 
    }
    return psd;
  }

  // Calculate integrated power for a specific frequency band
  double getBandPower(List<double> psd, double lowFreq, double highFreq) {
    double power = 0.0;
    double freqResolution = sampleRate / bufferSize;
    
    int startIndex = (lowFreq / freqResolution).floor();
    int endIndex = (highFreq / freqResolution).ceil();
    
    for (int i = startIndex; i <= endIndex && i < psd.length; i++) {
      power += psd[i];
    }
    return power;
  }

  // Main entry point to process a (14 channels x 256 samples) buffer
  // Returns the Focus Index (0-100) or 0.0 if calibrating.
  double processBuffer(List<List<double>> multiChannelData) {
    if (multiChannelData.isEmpty) return 0.0;

    double totalTheta = 0.0;
    double totalAlpha = 0.0;
    double totalBeta = 0.0;

    for (var channelData in multiChannelData) {
      if (channelData.length != bufferSize) continue;

      var psd = calculatePsd(channelData);
      totalTheta += getBandPower(psd, 4.0, 8.0);
      totalAlpha += getBandPower(psd, 8.0, 13.0);
      totalBeta += getBandPower(psd, 13.0, 30.0);
    }

    // Average across channels (Channel Fusion)
    int numChannels = multiChannelData.length;
    double theta = totalTheta / numChannels;
    double alpha = totalAlpha / numChannels;
    double beta = totalBeta / numChannels;

    // Engagement Index (EI) calculation
    double currentEi = 0.0;
    if ((alpha + theta) > 0) {
      currentEi = beta / (alpha + theta);
    }

    // 1. Calibration Phase
    if (isCalibrating) {
      _calibrationBuffer.add(currentEi);
      _calibrationSeconds++;
      
      // If we've collected enough seconds, finalize the baseline
      if (_calibrationSeconds >= maxCalibrationSeconds) {
        isCalibrating = false;
        _baseline = _calibrationBuffer.reduce((a, b) => a + b) / _calibrationBuffer.length;
        _ema = _baseline; // Initialize EMA with baseline
      }
      return 0.0; 
    }

    // 2. Post-Calibration Phase: Apply EMA Smoothing
    _ema = (currentEi * smoothingFactor) + (_ema * (1 - smoothingFactor));

    // 3. Normalize against baseline
    double eiNorm = _ema / _baseline;

    // 4. Update dynamic Min/Max for scaling
    if (eiNorm < _minEi) _minEi = eiNorm;
    if (eiNorm > _maxEi) _maxEi = eiNorm;

    // 5. Scale to 0-100
    if (_maxEi == _minEi) return 50.0; // Avoid division by zero
    
    double focusIndex = 100 * ((eiNorm - _minEi) / (_maxEi - _minEi));
    
    // Clip and return
    return max(0.0, min(100.0, focusIndex));
  }
  
  // Resets the session
  void reset() {
    isCalibrating = true;
    _calibrationBuffer.clear();
    _calibrationSeconds = 0;
    _minEi = double.maxFinite;
    _maxEi = -double.maxFinite;
    _ema = 0.0;
  }
}
