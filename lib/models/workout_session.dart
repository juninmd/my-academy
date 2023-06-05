import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class WorkoutSession {
  int id;
  int workoutId;
  DateTime date;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.date,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      workoutId: json['workoutId'],
      date: json['date'],
    );
  }
}
