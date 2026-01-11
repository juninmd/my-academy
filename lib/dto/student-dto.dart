import 'package:json_annotation/json_annotation.dart';

import '../features/students/domain/entities/student_entity.dart';

@JsonSerializable()
class StudentDto {
  StudentDto({required this.student, required this.schedule});

  factory StudentDto.fromJson(Map<String, dynamic> json) => StudentDto(
    student: StudentEntity(
      id: json['student']['id'] ?? '',
      name: json['student']['name'] ?? '',
      email: json['student']['email'] ?? '',
      photoUrl: json['student']['photoUrl'],
    ),
    schedule: json['schedule'] != null ? [] : [],
  );
  StudentEntity student;
  List<dynamic> schedule;
}
