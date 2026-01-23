import 'package:equatable/equatable.dart';
import 'workout_entity.dart';

class WorkoutGroupEntity extends Equatable {
  const WorkoutGroupEntity({
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
  final List<WorkoutEntity> workouts;

  WorkoutGroupEntity copyWith({
    int? id,
    String? name,
    String? image,
    String? userId,
    List<WorkoutEntity>? workouts,
  }) {
    return WorkoutGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      userId: userId ?? this.userId,
      workouts: workouts ?? this.workouts,
    );
  }

  @override
  List<Object?> get props => [id, name, image, userId, workouts];
}
