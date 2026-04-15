import '../../domain/entities/workout_entity.dart';
import 'exercise_dto.dart';
import 'workout_series_dto.dart';

class WorkoutDto {
  const WorkoutDto({
    required this.exerciseId,
    this.id,
    this.methodId,
    this.description,
    this.exercise,
    this.series = const [],
  });

  final int? id;
  final int exerciseId;
  final int? methodId;
  final String? description;
  final ExerciseDto? exercise;
  final List<WorkoutSeriesDto> series;

  factory WorkoutDto.fromJson(Map<String, dynamic> json) {
    return WorkoutDto(
      id: json['id'] as int?,
      exerciseId: json['exerciseId'] as int,
      methodId: json['methodId'] as int?,
      description: json['description'] as String?,
      exercise:
          json['exercise'] != null
              ? ExerciseDto.fromJson(json['exercise'] as Map<String, dynamic>)
              : null,
      series:
          (json['workoutSeries'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(WorkoutSeriesDto.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exerciseId': exerciseId,
      if (methodId != null) 'methodId': methodId,
      if (description != null) 'description': description,
      if (exercise != null) 'exercise': exercise!.toJson(),
      if (series.isNotEmpty)
        'workoutSeries': series.map((s) => s.toJson()).toList(),
    };
  }

  WorkoutEntity toEntity() {
    return WorkoutEntity(
      id: id,
      exerciseId: exerciseId,
      methodId: methodId,
      description: description,
      exercise: exercise?.toEntity(),
      series: series.map((s) => s.toEntity()).toList(),
      isFinished: false,
    );
  }

  factory WorkoutDto.fromEntity(WorkoutEntity entity) {
    return WorkoutDto(
      id: entity.id,
      exerciseId: entity.exerciseId,
      methodId: entity.methodId,
      description: entity.description,
      exercise:
          entity.exercise != null
              ? ExerciseDto.fromEntity(entity.exercise!)
              : null,
      series: entity.series.map((s) => WorkoutSeriesDto.fromEntity(s)).toList(),
    );
  }
}
