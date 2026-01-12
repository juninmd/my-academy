import 'package:equatable/equatable.dart';

class WorkoutSummaryEntity extends Equatable {
  const WorkoutSummaryEntity({
    required this.counter,
    required this.hasWorkoutToday,
    this.lastSessionDate,
    this.workoutName,
    this.personalName,
  });
  final int counter;
  final String? lastSessionDate; // Simplified for display
  final String? workoutName;
  final String? personalName;
  final bool hasWorkoutToday;

  @override
  List<Object?> get props => [
    counter,
    lastSessionDate,
    workoutName,
    personalName,
    hasWorkoutToday,
  ];
}
