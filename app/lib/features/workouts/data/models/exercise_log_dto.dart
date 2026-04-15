import '../../domain/entities/exercise_log_entity.dart';
import 'set_log_dto.dart';

class ExerciseLogDto {
  const ExerciseLogDto({
    required this.exerciseId,
    required this.date,
    required this.sets,
    required this.userId,
    this.id,
    this.notes,
  });

  final String? id;
  final String userId;
  final int exerciseId;
  final DateTime date;
  final List<SetLogDto> sets;
  final String? notes;

  factory ExerciseLogDto.fromJson(Map<String, dynamic> json) {
    return ExerciseLogDto(
      id: json['id']?.toString(),
      userId: json['userId'] as String,
      exerciseId: json['exerciseId'] as int,
      date: DateTime.parse(json['date'] as String),
      sets:
          (json['sets'] as List?)
              ?.map((e) => SetLogDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'sets': sets.map((s) => s.toJson()).toList(),
      if (notes != null) 'notes': notes,
    };
  }

  ExerciseLogEntity toEntity() {
    return ExerciseLogEntity(
      id: id,
      userId: userId,
      exerciseId: exerciseId,
      date: date,
      sets: sets.map((s) => s.toEntity()).toList(),
      notes: notes,
    );
  }

  factory ExerciseLogDto.fromEntity(ExerciseLogEntity entity) {
    return ExerciseLogDto(
      id: entity.id,
      userId: entity.userId,
      exerciseId: entity.exerciseId,
      date: entity.date,
      sets: entity.sets.map((s) => SetLogDto.fromEntity(s)).toList(),
      notes: entity.notes,
    );
  }
}
