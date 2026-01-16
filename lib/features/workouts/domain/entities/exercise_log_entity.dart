import 'package:equatable/equatable.dart';
import 'set_log_entity.dart';

class ExerciseLogEntity extends Equatable {
  const ExerciseLogEntity({
    required this.exerciseId,
    required this.date,
    required this.sets,
    required this.userId,
    this.id,
    this.notes,
  });

  final String? id;
  final String userId;
  final int exerciseId;
  final DateTime date;
  final List<SetLogEntity> sets;
  final String? notes;

  @override
  List<Object?> get props => [id, userId, exerciseId, date, sets, notes];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseLogEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseLogEntity(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      exerciseId: json['exerciseId'] as int,
      date: DateTime.parse(json['date'] as String),
      sets: (json['sets'] as List)
          .map((e) => SetLogEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}
