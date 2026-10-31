import '../../domain/entities/invite_entity.dart';

/// Maps `GET /invites`.
class InviteDto {
  const InviteDto._();

  static InviteEntity fromJson(Map<String, dynamic> json) {
    return InviteEntity(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
    );
  }
}
