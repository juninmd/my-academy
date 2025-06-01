import "package:json_annotation/json_annotation.dart";

import '../models/user.dart';
import '../models/workout_group.dart';
import '../models/workout_session.dart';

@JsonSerializable()
class WorkoutSummary {
  WorkoutSession? lastSession;
  int counter;
  WorkoutGroup? workoutGroupOfDay;
  Users? personal;

  WorkoutSummary({
    this.lastSession,
    this.personal,
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
    personal: json['personal'] != null
        ? Users.fromJson(json['personal'])
        : null,
        // Convert string to DateTime object
      );
}
