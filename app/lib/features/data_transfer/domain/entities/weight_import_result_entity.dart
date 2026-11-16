class WeightImportResultEntity {
  const WeightImportResultEntity({
    required this.format,
    required this.imported,
    required this.skippedExisting,
    required this.skippedRows,
  });

  /// `apple-health` or `csv`, as the server read the file.
  final String format;
  final int imported;
  final int skippedExisting;
  final int skippedRows;
}
