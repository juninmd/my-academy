import 'package:equatable/equatable.dart';

class SetLogEntity extends Equatable {
  const SetLogEntity({required this.reps, required this.weight, this.rpe});

  final int reps;
  final int weight;
  final int? rpe;

  @override
  List<Object?> get props => [reps, weight, rpe];

  Map<String, dynamic> toJson() {
    return {'reps': reps, 'weight': weight, 'rpe': rpe};
  }

  factory SetLogEntity.fromJson(Map<String, dynamic> json) {
    return SetLogEntity(
      reps: json['reps'] as int,
      weight: json['weight'] as int,
      rpe: json['rpe'] as int?,
    );
  }
}
