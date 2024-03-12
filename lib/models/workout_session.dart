import "package:json_annotation/json_annotation.dart";

import 'workout_group.dart';

@JsonSerializable()
class WorkoutSession {
  int? id;
  int workoutGroupId;
  DateTime date;
  WorkoutGroup? workoutsGroups;

  WorkoutSession({
    this.id,
    this.workoutsGroups,
    required this.workoutGroupId,
    required this.date,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'],
        workoutGroupId: json['workoutGroupId'],
        workoutsGroups: json['workoutsGroups'] != null
            ? WorkoutGroup.fromJson(json['workoutsGroups'])
            : null,
        date: DateTime.parse(json['date']).toLocal(), // Convert string to DateTime object
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'workoutGroupId': workoutGroupId,
        'date': date.toUtc().toIso8601String(),
      };
}
