import '../../domain/entities/workout_group_entity.dart';
import 'workout_dto.dart';

class WorkoutGroupDto {
  const WorkoutGroupDto({
    required this.name,
    required this.userId,
    this.id,
    this.image,
    this.workouts = const [],
  });

  final int? id;
  final String name;
  final String? image;
  final String userId;
  final List<WorkoutDto> workouts;

  factory WorkoutGroupDto.fromJson(Map<String, dynamic> json) {
    return WorkoutGroupDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      image: json['image'] as String?,
      userId: json['userId'] as String,
      workouts:
          (json['workouts'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(WorkoutDto.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (image != null) 'image': image,
      'userId': userId,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }

  WorkoutGroupEntity toEntity() {
    return WorkoutGroupEntity(
      id: id,
      name: name,
      image: image,
      userId: userId,
      workouts: workouts.map((w) => w.toEntity()).toList(),
    );
  }

  factory WorkoutGroupDto.fromEntity(WorkoutGroupEntity entity) {
    return WorkoutGroupDto(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      userId: entity.userId,
      workouts: entity.workouts.map((w) => WorkoutDto.fromEntity(w)).toList(),
    );
  }
}
