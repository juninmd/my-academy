import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/utils/one_rep_max_calculator.dart';

void main() {
  group('OneRepMaxCalculator', () {
    test('calculateEpley returns correct value for standard input', () {
      // Formula: weight * (1 + reps/30)
      // 100 * (1 + 10/30) = 100 * (1 + 0.333...) = 133.33...
      final rm = OneRepMaxCalculator.calculateEpley(100, 10);
      expect(rm, closeTo(133.33, 0.01));
    });

    test('calculateEpley returns weight for 1 rep', () {
      final rm = OneRepMaxCalculator.calculateEpley(100, 1);
      expect(rm, 100.0);
    });

    test('calculateEpley handles zero inputs', () {
      expect(OneRepMaxCalculator.calculateEpley(0, 10), 0.0);
      expect(OneRepMaxCalculator.calculateEpley(100, 0), 0.0);
    });
  });
}
