import '../../domain/entities/workout_series_entity.dart';

class WorkoutSeriesDto {
  const WorkoutSeriesDto({
    required this.repetitions,
    required this.weight,
    required this.rest,
    this.id,
    this.workoutId,
    this.time,
    this.distance,
    this.speed,
  });

  final int? id;
  final int? workoutId;
  final int repetitions;
  final int weight;
  final int rest;
  final int? time;
  final double? distance;
  final double? speed;

  factory WorkoutSeriesDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSeriesDto(
      id: json['id'] as int?,
      workoutId: json['workoutId'] as int?,
      repetitions: json['repetitions'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      rest: json['rest'] as int? ?? 0,
      time: json['time'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (workoutId != null) 'workoutId': workoutId,
      'repetitions': repetitions,
      'weight': weight,
      'rest': rest,
      if (time != null) 'time': time,
      if (distance != null) 'distance': distance,
      if (speed != null) 'speed': speed,
    };
  }

  WorkoutSeriesEntity toEntity() {
    return WorkoutSeriesEntity(
      id: id,
      workoutId: workoutId,
      repetitions: repetitions,
      weight: weight,
      rest: rest,
      time: time,
      distance: distance,
      speed: speed,
    );
  }

  factory WorkoutSeriesDto.fromEntity(WorkoutSeriesEntity entity) {
    return WorkoutSeriesDto(
      id: entity.id,
      workoutId: entity.workoutId,
      repetitions: entity.repetitions,
      weight: entity.weight,
      rest: entity.rest,
      time: entity.time,
      distance: entity.distance,
      speed: entity.speed,
    );
  }
}
