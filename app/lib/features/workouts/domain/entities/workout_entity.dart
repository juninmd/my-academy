import 'package:equatable/equatable.dart';
import 'exercise_entity.dart';
import 'workout_series_entity.dart';

class WorkoutEntity extends Equatable {
  const WorkoutEntity({
    required this.exerciseId,
    this.id,
    this.methodId,
    this.description,
    this.exercise,
    this.series = const [],
    this.isFinished = false,
    this.supersetGroup,
  });
  final int? id;
  final int exerciseId;
  final int? methodId;
  final String? description; // Instructions specific to this workout
  final ExerciseEntity? exercise;
  final List<WorkoutSeriesEntity> series;
  final bool isFinished;
  /// Exercises with the same label are one superset.
  final String? supersetGroup;

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    methodId,
    description,
    exercise,
    series,
    isFinished,
    supersetGroup,
  ];

  WorkoutEntity copyWith({
    int? id,
    int? exerciseId,
    int? methodId,
    String? description,
    ExerciseEntity? exercise,
    List<WorkoutSeriesEntity>? series,
    bool? isFinished,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      methodId: methodId ?? this.methodId,
      description: description ?? this.description,
      exercise: exercise ?? this.exercise,
      series: series ?? this.series,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
