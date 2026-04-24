import 'package:equatable/equatable.dart';

class WorkoutSeriesEntity extends Equatable {
  const WorkoutSeriesEntity({
    required this.id,
    required this.workoutId,
    required this.repetitions,
    required this.weight,
    required this.rest,
    this.rpe,
    this.time,
    this.distance,
    this.speed,
  });

  final int id;
  final int workoutId;
  final int repetitions;
  final double weight;
  final int rest;
  final double? rpe;
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
    rpe,
    time,
    distance,
    speed,
  ];
}
