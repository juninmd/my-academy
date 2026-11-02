class ImportResultEntity {
  const ImportResultEntity({
    required this.logs,
    required this.sets,
    required this.skippedExisting,
    required this.skippedRows,
    required this.unmatchedExercises,
  });

  final int logs;
  final int sets;
  final int skippedExisting;
  final int skippedRows;
  final List<String> unmatchedExercises;
}
