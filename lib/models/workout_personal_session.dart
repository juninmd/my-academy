import "package:json_annotation/json_annotation.dart";

import 'user.dart';

@JsonSerializable()
class WorkoutPersonalSession {
  int? id;
  int personalsId;
  String userId;
  DateTime date;
  Users users;

  WorkoutPersonalSession({
    this.id,
    required this.personalsId,
    required this.userId,
    required this.date,
    required this.users,
  });

  factory WorkoutPersonalSession.fromJson(Map<String, dynamic> json) =>
      WorkoutPersonalSession(
          id: json['id'],
          personalsId: json['personalsId'],
          userId: json['userId'],
          date:
              DateTime.parse(json['date']).toLocal(), // Convert string to DateTime object
          users: Users.fromJson(json['users']));

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'personalsId': personalsId,
        'userId': userId,
        'date': date.toUtc().toIso8601String(),
      };
}
