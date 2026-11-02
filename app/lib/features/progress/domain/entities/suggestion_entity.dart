class SuggestionEntity {
  const SuggestionEntity({
    required this.weight,
    required this.reps,
    required this.sets,
    required this.deload,
    required this.reason,
  });

  final double weight;
  final int reps;
  final int sets;
  final bool deload;
  final String reason;
}
