import 'package:equatable/equatable.dart';

class WorkoutSessionEntity extends Equatable {
  const WorkoutSessionEntity({
    required this.workoutGroupId,
    required this.date,
    required this.checked,
    required this.userId,
    this.id,
    this.createdAt,
  });
  final int? id;
  final int workoutGroupId;
  final DateTime date;
  final bool checked;
  final String userId;

  /// When the session was logged; `date` only carries the day.
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    workoutGroupId,
    date,
    checked,
    userId,
    createdAt,
  ];
}
