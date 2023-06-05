import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class WorkoutSeries {
  int id;
  int workoutId;
  int repetitions;
  int weight;
  int rest;

  WorkoutSeries({
    required this.id,
    required this.workoutId,
    required this.repetitions,
    required this.weight,
    required this.rest,
  });

  factory WorkoutSeries.fromJson(Map<String, dynamic> json) {
    return WorkoutSeries(
      id: json['id'],
      workoutId: json['workoutId'],
      repetitions: json['repetitions'],
      weight: json['weight'],
      rest: json['rest'],
    );
  }
}
