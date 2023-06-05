import "package:json_annotation/json_annotation.dart";

@JsonSerializable()
class Personal {
  int id;
  int userId;

  Personal({
    required this.id,
    required this.userId,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      id: json['id'],
      userId: json['userId'],
    );
  }
}
