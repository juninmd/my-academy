import "package:json_annotation/json_annotation.dart";

import 'workout.dart';

@JsonSerializable()
class WorkoutGroup {
  int id;
  String name;
  String description;
  String image;
  DateTime dateStart;
  DateTime dateEnd;
  int level;
  int userId;
  List<Workout>? workouts;

  WorkoutGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.dateStart,
    required this.dateEnd,
    required this.level,
    required this.userId,
    this.workouts,
  });

  factory WorkoutGroup.fromJson(Map<String, dynamic> json) {
    return WorkoutGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json?['image'] ?? '',
      dateStart: DateTime.parse(json['dateStart']),
      dateEnd: DateTime.parse(json['dateEnd']),
      level: json['level'],
      userId: json['userId'],
      workouts: json['workouts'] != null
          ? List<Workout>.from(
              json['workouts'].map((workout) => Workout.fromJson(workout)))
          : null,
    );
  }
}
