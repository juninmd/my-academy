class OneRepMaxCalculator {
  /// Calculates the estimated 1RM using the Epley formula.
  /// Formula: Weight * (1 + (Reps / 30))
  static double calculateEpley(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + (reps / 30.0));
  }
}
