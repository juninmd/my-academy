import "package:json_annotation/json_annotation.dart";

import '../models/schedule.dart';
import '../models/user.dart';

@JsonSerializable()
class StudentDto {
  Users student;
  List<Schedule> schedule;

  StudentDto({
    required this.student,
    required this.schedule,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) {
    return StudentDto(
        student: Users.fromJson(json['student']),
        schedule: List<Schedule>.from(json['schedule'].map((schedule) => Schedule.fromJson(schedule))));
  }
}
