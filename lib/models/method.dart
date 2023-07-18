import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Method {
  int id;
  String name;
  String description;

  Method({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Method.fromJson(Map<String, dynamic> json) {
    return Method(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }
}
