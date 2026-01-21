import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/utils/body_composition_calculator.dart';

void main() {
  group('BodyCompositionCalculator', () {
    group('calculateBodyDensityMen', () {
      test('should calculate correct body density for men', () {
        // Example data
        // Sum of skinfolds = 100
        // Age = 30
        const double chest = 15.0;
        const double axilla = 15.0;
        const double triceps = 15.0;
        const double subscapular = 15.0;
        const double abdominal = 15.0;
        const double suprailiac = 15.0;
        const double thigh = 10.0;
        const int age = 30;

        // Formula: 1.112 - (0.00043499 * sum) + (0.00000055 * sum * sum) - (0.00028826 * age)
        // Sum = 100
        // 1.112 - 0.043499 + 0.0055 - 0.0086478 = 1.0653532

        final result = BodyCompositionCalculator.calculateBodyDensityMen(
          chest: chest,
          axilla: axilla,
          triceps: triceps,
          subscapular: subscapular,
          abdominal: abdominal,
          suprailiac: suprailiac,
          thigh: thigh,
          age: age,
        );

        expect(result, closeTo(1.0653532, 0.000001));
      });
    });

    group('calculateBodyDensityWomen', () {
      test('should calculate correct body density for women', () {
        // Example data
        // Sum of skinfolds = 100
        // Age = 30
        const double chest = 15.0;
        const double axilla = 15.0;
        const double triceps = 15.0;
        const double subscapular = 15.0;
        const double abdominal = 15.0;
        const double suprailiac = 15.0;
        const double thigh = 10.0;
        const int age = 30;

        // Formula: 1.097 - (0.00046971 * sum) + (0.00000056 * sum * sum) - (0.00012828 * age)
        // Sum = 100
        // 1.097 - 0.046971 + 0.0056 - 0.0038484 = 1.0517806

        final result = BodyCompositionCalculator.calculateBodyDensityWomen(
          chest: chest,
          axilla: axilla,
          triceps: triceps,
          subscapular: subscapular,
          abdominal: abdominal,
          suprailiac: suprailiac,
          thigh: thigh,
          age: age,
        );

        expect(result, closeTo(1.0517806, 0.000001));
      });
    });

    group('calculateBodyFatPercentage', () {
      test('should calculate correct body fat percentage from density', () {
        const double density = 1.0653532;
        // Formula: ((4.95 / density) - 4.50) * 100
        // (4.646346... - 4.50) * 100 = 14.6346...

        final result =
            BodyCompositionCalculator.calculateBodyFatPercentage(density);

        expect(result, closeTo(14.6346, 0.001));
      });
    });
  });
}
