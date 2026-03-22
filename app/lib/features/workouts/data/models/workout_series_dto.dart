import '../../domain/entities/workout_series_entity.dart';

class WorkoutSeriesDto {
  const WorkoutSeriesDto({
    required this.repetitions,
    required this.weight,
    required this.rest,
    this.id,
    this.workoutId,
  });

  final int? id;
  final int? workoutId;
  final int repetitions;
  final int weight;
  final int rest;

  factory WorkoutSeriesDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSeriesDto(
      id: json['id'] as int?,
      workoutId: json['workoutId'] as int?,
      repetitions: json['repetitions'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      rest: json['rest'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (workoutId != null) 'workoutId': workoutId,
      'repetitions': repetitions,
      'weight': weight,
      'rest': rest,
    };
  }

  WorkoutSeriesEntity toEntity() {
    return WorkoutSeriesEntity(
      id: id,
      workoutId: workoutId,
      repetitions: repetitions,
      weight: weight,
      rest: rest,
    );
  }

  factory WorkoutSeriesDto.fromEntity(WorkoutSeriesEntity entity) {
    return WorkoutSeriesDto(
      id: entity.id,
      workoutId: entity.workoutId,
      repetitions: entity.repetitions,
      weight: entity.weight,
      rest: entity.rest,
    );
  }
}
