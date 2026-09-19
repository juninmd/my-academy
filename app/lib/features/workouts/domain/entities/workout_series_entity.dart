import 'package:equatable/equatable.dart';

class WorkoutSeriesEntity extends Equatable {
  // in seconds

  const WorkoutSeriesEntity({
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
  final double weight; // in kg or unit
  final int rest;
  final int? time;
  final double? distance;
  final double? speed;

  @override
  List<Object?> get props => [
    id,
    workoutId,
    repetitions,
    weight,
    rest,
    time,
    distance,
    speed,
  ];

  WorkoutSeriesEntity copyWith({
    int? id,
    int? workoutId,
    int? repetitions,
    double? weight,
    int? rest,
    int? time,
    double? distance,
    double? speed,
  }) {
    return WorkoutSeriesEntity(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
      rest: rest ?? this.rest,
      time: time ?? this.time,
      distance: distance ?? this.distance,
      speed: speed ?? this.speed,
    );
  }
}
