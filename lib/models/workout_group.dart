import "package:json_annotation/json_annotation.dart";

import 'workout.dart';

@JsonSerializable()
class WorkoutGroup {
  int? id;
  String name;
  String image;
  int userId;
  List<Workout>? workouts;

  WorkoutGroup({
    this.id,
    required this.name,
    required this.image,
    required this.userId,
    this.workouts,
  });

  factory WorkoutGroup.fromJson(Map<String, dynamic> json) {
    return WorkoutGroup(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      userId: json['userId'],
      workouts: json['workouts'] != null
          ? List<Workout>.from(
              json['workouts'].map((workout) => Workout.fromJson(workout)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'image': image,
      'userId': userId,
      if (workouts != null)
        'workouts': workouts!.map((workout) => workout.toJson()).toList(),
    };
  }
}
