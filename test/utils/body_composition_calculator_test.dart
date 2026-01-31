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

    group('calculateBodyDensityMen3Site', () {
      test('should calculate correct body density for men (3 site)', () {
        // Example data
        // Sum of skinfolds = 60
        // Age = 30
        const double chest = 20.0;
        const double abdominal = 20.0;
        const double thigh = 20.0;
        const int age = 30;

        // Formula: 1.10938 - (0.0008267 * sum) + (0.0000016 * sum * sum) - (0.0002574 * age)
        // Sum = 60
        // 1.10938 - 0.049602 + 0.00576 - 0.007722 = 1.057816

        final result = BodyCompositionCalculator.calculateBodyDensityMen3Site(
          chest: chest,
          abdominal: abdominal,
          thigh: thigh,
          age: age,
        );

        expect(result, closeTo(1.057816, 0.000001));
      });
    });

    group('calculateBodyDensityWomen3Site', () {
      test('should calculate correct body density for women (3 site)', () {
        // Example data
        // Sum of skinfolds = 60
        // Age = 30
        const double triceps = 20.0;
        const double suprailiac = 20.0;
        const double thigh = 20.0;
        const int age = 30;

        // Formula: 1.0994921 - (0.0009929 * sum) + (0.0000023 * sum * sum) - (0.0001392 * age)
        // Sum = 60
        // 1.0994921 - 0.059574 + 0.00828 - 0.004176 = 1.0440221

        final result = BodyCompositionCalculator.calculateBodyDensityWomen3Site(
          triceps: triceps,
          suprailiac: suprailiac,
          thigh: thigh,
          age: age,
        );

        expect(result, closeTo(1.0440221, 0.000001));
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
