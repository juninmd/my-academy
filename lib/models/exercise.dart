import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Exercise {
  int id;
  String name;
  String image;
  List<String> tips;
  List<String> mistakes;
  String description;

  Exercise({
    required this.id,
    required this.name,
    required this.image,
    required this.tips,
    required this.mistakes,
    required this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      tips: json['tips'].split(', '),
      mistakes: json['mistakes'].split(', '),
      description: json['description'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'image': image,
      'tips': tips,
      'mistakes': mistakes,
      'description': description,
    };
  }
}
