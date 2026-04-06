import '../../domain/entities/set_log_entity.dart';

class SetLogDto {
  const SetLogDto({
    required this.reps,
    required this.weight,
    this.rpe,
    this.type = SetType.normal,
  });

  final int reps;
  final int weight;
  final int? rpe;
  final SetType type;

  factory SetLogDto.fromJson(Map<String, dynamic> json) {
    return SetLogDto(
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

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      if (rpe != null) 'rpe': rpe,
      'type': type.name,
    };
  }

  SetLogEntity toEntity() {
    return SetLogEntity(
      reps: reps,
      weight: weight,
      rpe: rpe,
      type: type,
    );
  }

  factory SetLogDto.fromEntity(SetLogEntity entity) {
    return SetLogDto(
      reps: entity.reps,
      weight: entity.weight,
      rpe: entity.rpe,
      type: entity.type,
    );
  }
}
