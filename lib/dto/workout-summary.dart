import "package:json_annotation/json_annotation.dart";

import '../models/user.dart';
import '../models/workout_group.dart';
import '../models/workout_session.dart';

@JsonSerializable()
class WorkoutSummary {
  WorkoutSession? lastSession;
  int counter;
  WorkoutGroup? workoutGroupOfDay;
  User? user;
  User? personal;
  List<User>? students;

  WorkoutSummary({
    this.lastSession,
    this.user,
    this.personal,
    this.students,
    required this.counter,
    this.workoutGroupOfDay,
  });

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) => WorkoutSummary(
        lastSession: json['lastSession'] != null
            ? WorkoutSession.fromJson(json['lastSession'])
            : null,
        counter: json['counter'],
        workoutGroupOfDay: json['workoutGroupOfDay'] != null
            ? WorkoutGroup.fromJson(json['workoutGroupOfDay'])
            : null,
    user: json['user'] != null
        ? User.fromJson(json['user'])
        : null,
    personal: json['personal'] != null
        ? User.fromJson(json['personal'])
        : null,
    students: json['students'] != null
        ? List<User>.from(
        json['students'].map((student) => User.fromJson(student)))
        : null,
        // Convert string to DateTime object
      );
}
