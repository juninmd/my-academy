import 'package:json_annotation/json_annotation.dart';
import 'package:my_academy/models/workout_series.dart';

import 'exercise.dart';
import 'method.dart';

@JsonSerializable()
class Workout {
  int? id;
  int exerciseId;
  int? methodId;
  String description;
  Exercise? exercise;
  Method? method;
  List<WorkoutSeries>? workoutSeries = [];
  bool finish;

  Workout({
    this.id,
    this.methodId,
    required this.exerciseId,
    required this.description,
    this.workoutSeries,
    this.exercise,
    this.method,
    this.finish = false,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      exerciseId: json['exerciseId'],
      description: json['description'],
      exercise: Exercise.fromJson(json['exercise']),
      method: json['method'] != null ? Method.fromJson(json['method']) : null,
      workoutSeries: json['workoutSeries'] != null
          ? List<WorkoutSeries>.from(json['workoutSeries']
              .map((workoutSeries) => WorkoutSeries.fromJson(workoutSeries)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exerciseId': exerciseId,
      'methodId': methodId,
      'description': description,
      'exercise': exercise?.toJson(),
      'method': method?.toJson(),
      'workoutSeries': workoutSeries?.map((series) => series.toJson()).toList(),
      'finish': finish,
    };
  }
}
