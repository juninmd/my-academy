import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class Student {
  int id;
  String userId;
  int? personalsId;

  Student({
    required this.id,
    required this.userId,
    required this.personalsId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      userId: json['userId'],
      personalsId: json['personalsId'],
    );
  }
}
