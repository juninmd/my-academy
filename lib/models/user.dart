import "package:json_annotation/json_annotation.dart";
import 'package:my_academy/models/personal.dart';
import 'package:my_academy/models/student.dart';

@JsonSerializable()
class User {
  int id;
  String name;
  String email;
  List<Personal>? personals;
  List<Student>? students;
  // WorkoutsGroups workoutsGroups;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.personals,
    this.students,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        personals: json['personals'] != null
            ? List<Personal>.from(json['personals']
                .map((personal) => Personal.fromJson(personal)))
            : null,
        students: json['students'] != null
            ? List<Student>.from(
                json['students'].map((student) => Student.fromJson(student)))
            : null,
      );
}
