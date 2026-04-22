import '../../domain/entities/method_entity.dart';

class MethodDto {
  const MethodDto({
    this.id,
    required this.name,
    this.description,
  });

  final int? id;
  final String name;
  final String? description;

  factory MethodDto.fromJson(Map<String, dynamic> json) {
    return MethodDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }

  MethodEntity toEntity() {
    return MethodEntity(
      id: id ?? 0,
      name: name,
      description: description,
    );
  }

  factory MethodDto.fromEntity(MethodEntity entity) {
    return MethodDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }
}
