import 'package:flutter_test/flutter_test.dart';
import 'package:haze_clue/core/utils/focus_calculator.dart';

void main() {
  group('FocusCalculator Dart Unit Tests', () {
    late FocusCalculator calculator;

    setUp(() {
      calculator = FocusCalculator();
    });

    test('Initial state is calibrating', () {
      expect(calculator.isCalibrating, isTrue);
    });

    test('Returns 0.0 during the calibration phase', () {
      List<List<double>> dummyBuffer = List.generate(14, (_) => List.filled(256, 0.0));
      double result = calculator.processBuffer(dummyBuffer);
      expect(result, 0.0);
    });

    test('Finishes calibration after maxCalibrationSeconds and outputs scores', () {
      // Create a dummy sine wave buffer to ensure non-zero power
      List<List<double>> dummyBuffer = List.generate(14, (_) {
        return List.generate(256, (i) => i.toDouble() % 10);
      });
      
      for (int i = 0; i < calculator.maxCalibrationSeconds; i++) {
        expect(calculator.isCalibrating, isTrue);
        double result = calculator.processBuffer(dummyBuffer);
        expect(result, 0.0);
      }
      
      // The very next call should be post-calibration and return 50.0 (because min == max initially)
      expect(calculator.isCalibrating, isFalse);
      double score = calculator.processBuffer(dummyBuffer);
      expect(score, inInclusiveRange(0.0, 100.0));
    });
    
    test('calculatePsd returns correct length list', () {
      List<double> dummyChannel = List.filled(256, 1.0);
      var psd = calculator.calculatePsd(dummyChannel);
      // For full Radix-2 FFT of size 256, we expect 256 bins
      expect(psd.length, 256); 
    });

    test('reset function correctly resets state', () {
      calculator.isCalibrating = false;
      calculator.reset();
      expect(calculator.isCalibrating, isTrue);
    });
  });
}
