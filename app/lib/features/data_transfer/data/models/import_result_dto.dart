import '../../domain/entities/import_result_entity.dart';

/// Maps the response of `POST /imports/csv`, `/imports/json` and `/imports/hevy`.
class ImportResultDto {
  const ImportResultDto._();

  static ImportResultEntity fromJson(Map<String, dynamic> json) {
    final imported = json['imported'] as Map<String, dynamic>? ?? {};
    return ImportResultEntity(
      logs: (imported['logs'] as num?)?.toInt() ?? 0,
      sets: (imported['sets'] as num?)?.toInt() ?? 0,
      skippedExisting: (json['skippedExisting'] as num?)?.toInt() ?? 0,
      skippedRows: (json['skippedRows'] as num?)?.toInt() ?? 0,
      unmatchedExercises: (json['unmatchedExercises'] as List<dynamic>? ?? [])
          .cast<String>(),
    );
  }
}
