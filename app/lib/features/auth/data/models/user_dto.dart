import '../../domain/entities/user_entity.dart';

class UserDto extends UserEntity {
  const UserDto({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.role,
  });
  factory UserDto.fromEntity(UserEntity entity) => UserDto(
    id: entity.id,
    email: entity.email,
    name: entity.name,
    photoUrl: entity.photoUrl,
    role: entity.role,
  );

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String?,
    photoUrl: json['photoUrl'] as String?,
    role: json['role'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (name != null) 'name': name,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (role != null) 'role': role,
  };
}
