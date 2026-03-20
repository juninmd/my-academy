import 'package:equatable/equatable.dart';

enum SetType {
  normal,
  warmup,
  dropset,
  failure
}

class SetLogEntity extends Equatable {
  const SetLogEntity({
    required this.reps,
    required this.weight,
    this.rpe,
    this.type = SetType.normal,
  });

  final int reps;
  final int weight;
  final int? rpe;
  final SetType type;

  @override
  List<Object?> get props => [reps, weight, rpe, type];

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'type': type.name, // Serialize as string
    };
  }

  factory SetLogEntity.fromJson(Map<String, dynamic> json) {
    return SetLogEntity(
      reps: json['reps'] as int,
      weight: json['weight'] as int,
      rpe: json['rpe'] as int?,
      type: json['type'] != null
          ? SetType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => SetType.normal,
            )
          : SetType.normal,
    );
  }
}
