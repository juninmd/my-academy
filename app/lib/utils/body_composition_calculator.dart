class BodyCompositionCalculator {
  /// Calculate Body Density using Pollock 7-site formula for Men
  static double calculateBodyDensityMen({
    required double chest,
    required double axilla,
    required double triceps,
    required double subscapular,
    required double abdominal,
    required double suprailiac,
    required double thigh,
    required int age,
  }) {
    final sumSkinfolds =
        chest + axilla + triceps + subscapular + abdominal + suprailiac + thigh;

    return 1.112 -
        (0.00043499 * sumSkinfolds) +
        (0.00000055 * sumSkinfolds * sumSkinfolds) -
        (0.00028826 * age);
  }

  /// Calculate Body Density using Pollock 7-site formula for Women
  static double calculateBodyDensityWomen({
    required double chest,
    required double axilla,
    required double triceps,
    required double subscapular,
    required double abdominal,
    required double suprailiac,
    required double thigh,
    required int age,
  }) {
    final sumSkinfolds =
        chest + axilla + triceps + subscapular + abdominal + suprailiac + thigh;

    return 1.097 -
        (0.00046971 * sumSkinfolds) +
        (0.00000056 * sumSkinfolds * sumSkinfolds) -
        (0.00012828 * age);
  }

  /// Calculate Body Density using Jackson & Pollock 3-site formula for Men
  static double calculateBodyDensityMen3Site({
    required double chest,
    required double abdominal,
    required double thigh,
    required int age,
  }) {
    final sumSkinfolds = chest + abdominal + thigh;

    return 1.10938 -
        (0.0008267 * sumSkinfolds) +
        (0.0000016 * sumSkinfolds * sumSkinfolds) -
        (0.0002574 * age);
  }

  /// Calculate Body Density using Jackson & Pollock 3-site formula for Women
  static double calculateBodyDensityWomen3Site({
    required double triceps,
    required double suprailiac,
    required double thigh,
    required int age,
  }) {
    final sumSkinfolds = triceps + suprailiac + thigh;

    return 1.0994921 -
        (0.0009929 * sumSkinfolds) +
        (0.0000023 * sumSkinfolds * sumSkinfolds) -
        (0.0001392 * age);
  }

  /// Calculate Body Fat Percentage using Siri Equation
  static double calculateBodyFatPercentage(double bodyDensity) =>
      ((4.95 / bodyDensity) - 4.50) * 100;
}
