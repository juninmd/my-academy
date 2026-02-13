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

  WorkoutSeriesEntity copyWith({
    int? id,
    int? workoutId,
    int? repetitions,
    int? weight,
    int? rest,
  }) {
    return WorkoutSeriesEntity(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
      rest: rest ?? this.rest,
    );
  }
}
