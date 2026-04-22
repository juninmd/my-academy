import '../../domain/entities/personal_entity.dart';

class PersonalDto {
  const PersonalDto({
    this.id,
    required this.personalUserId,
    required this.studentUserId,
  });

  final int? id;
  final String personalUserId;
  final String studentUserId;

  factory PersonalDto.fromJson(Map<String, dynamic> json) {
    return PersonalDto(
      id: json['id'] as int?,
      personalUserId: json['personalUserId'] as String,
      studentUserId: json['studentUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'personalUserId': personalUserId,
      'studentUserId': studentUserId,
    };
  }

  PersonalEntity toEntity() {
    return PersonalEntity(
      id: id ?? 0,
      personalUserId: personalUserId,
      studentUserId: studentUserId,
    );
  }

  factory PersonalDto.fromEntity(PersonalEntity entity) {
    return PersonalDto(
      id: entity.id,
      personalUserId: entity.personalUserId,
      studentUserId: entity.studentUserId,
    );
  }
}
