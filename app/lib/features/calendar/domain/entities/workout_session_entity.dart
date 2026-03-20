import 'package:equatable/equatable.dart';

class WorkoutSessionEntity extends Equatable {
  const WorkoutSessionEntity({
    required this.workoutGroupId,
    required this.date,
    required this.checked,
    required this.userId,
    this.id,
  });
  final int? id;
  final int workoutGroupId;
  final DateTime date;
  final bool checked;
  final String userId;

  @override
  List<Object?> get props => [id, workoutGroupId, date, checked, userId];
}
