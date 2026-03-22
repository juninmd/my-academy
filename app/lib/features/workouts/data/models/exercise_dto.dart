import '../../domain/entities/exercise_entity.dart';

class ExerciseDto {
  const ExerciseDto({
    required this.id,
    required this.name,
    this.image,
    this.tips = const [],
    this.mistakes = const [],
    this.description,
  });

  final int id;
  final String name;
  final String? image;
  final List<String> tips;
  final List<String> mistakes;
  final String? description;

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      tips: json['tips'] != null ? (json['tips'] as String).split(',') : [],
      mistakes: json['mistakes'] != null ? (json['mistakes'] as String).split(',') : [],
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (image != null) 'image': image,
      if (tips.isNotEmpty) 'tips': tips.join(','),
      if (mistakes.isNotEmpty) 'mistakes': mistakes.join(','),
      if (description != null) 'description': description,
    };
  }

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id,
      name: name,
      image: image,
      tips: tips,
      mistakes: mistakes,
      description: description,
    );
  }

  factory ExerciseDto.fromEntity(ExerciseEntity entity) {
    return ExerciseDto(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      tips: entity.tips,
      mistakes: entity.mistakes,
      description: entity.description,
    );
  }
}
