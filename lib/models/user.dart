import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class User {
  int id;
  String name;
  String email;
  // Personals personals;
  // Students students;
  // WorkoutsGroups workoutsGroups;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
