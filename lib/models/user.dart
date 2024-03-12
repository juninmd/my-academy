import "package:json_annotation/json_annotation.dart";
import 'package:my_academy/models/personal.dart';
import 'package:my_academy/models/student.dart';

@JsonSerializable()
class Users {
  String id;
  String name;
  String email;
  String photoUrl;
  List<Personal>? personals;
  List<Student>? students;
  // WorkoutsGroups workoutsGroups;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.personals,
    this.students,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        photoUrl: json['photoUrl'],
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
