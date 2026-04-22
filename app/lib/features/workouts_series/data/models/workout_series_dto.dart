import '../../domain/entities/workout_series_entity.dart';

class WorkoutSeriesDto {
  const WorkoutSeriesDto({
    this.id,
    required this.workoutId,
    required this.repetitions,
    required this.weight,
    required this.rest,
    this.rpe,
    this.time,
    this.distance,
    this.speed,
  });

  final int? id;
  final int workoutId;
  final int repetitions;
  final double weight;
  final int rest;
  final double? rpe;
  final int? time;
  final double? distance;
  final double? speed;

  factory WorkoutSeriesDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSeriesDto(
      id: json['id'] as int?,
      workoutId: json['workoutId'] as int,
      repetitions: json['repetitions'] as int,
      weight: (json['weight'] as num).toDouble(),
      rest: json['rest'] as int,
      rpe: (json['rpe'] as num?)?.toDouble(),
      time: json['time'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'workoutId': workoutId,
      'repetitions': repetitions,
      'weight': weight,
      'rest': rest,
      if (rpe != null) 'rpe': rpe,
      if (time != null) 'time': time,
      if (distance != null) 'distance': distance,
      if (speed != null) 'speed': speed,
    };
  }

  WorkoutSeriesEntity toEntity() {
    return WorkoutSeriesEntity(
      id: id ?? 0,
      workoutId: workoutId,
      repetitions: repetitions,
      weight: weight,
      rest: rest,
      rpe: rpe,
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
      rpe: entity.rpe,
      time: entity.time,
      distance: entity.distance,
      speed: entity.speed,
    );
  }
}
