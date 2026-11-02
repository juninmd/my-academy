class InviteEntity {
  const InviteEntity({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.usedAt,
  });

  final int id;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? usedAt;

  bool get isUsed => usedAt != null;
  bool isExpiredAt(DateTime now) => !expiresAt.isAfter(now);
}
