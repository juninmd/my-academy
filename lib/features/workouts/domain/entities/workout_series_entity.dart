import 'package:equatable/equatable.dart';

class WorkoutSeriesEntity extends Equatable {
  // in seconds

  const WorkoutSeriesEntity({
    required this.repetitions,
    required this.weight,
    required this.rest,
    this.id,
    this.workoutId,
  });
  final int? id;
  final int? workoutId;
  final int repetitions;
  final int weight; // in kg or unit
  final int rest;

  @override
  List<Object?> get props => [id, workoutId, repetitions, weight, rest];
}
