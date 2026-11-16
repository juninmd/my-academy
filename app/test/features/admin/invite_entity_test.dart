import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/admin/data/models/invite_dto.dart';

void main() {
  test('maps an invite and its state', () {
    final invite = InviteDto.fromJson({
      'id': 4,
      'code': 'abc123',
      'createdAt': '2026-10-01T10:00:00.000Z',
      'expiresAt': '2026-10-08T10:00:00.000Z',
      'usedAt': null,
    });
    expect(invite.isUsed, isFalse);
    expect(invite.isExpiredAt(DateTime.utc(2026, 10, 2)), isFalse);
    expect(invite.isExpiredAt(DateTime.utc(2026, 10, 9)), isTrue);

    final used = InviteDto.fromJson({
      'id': 5,
      'code': 'x',
      'createdAt': '2026-10-01T10:00:00.000Z',
      'expiresAt': '2026-10-08T10:00:00.000Z',
      'usedAt': '2026-10-02T10:00:00.000Z',
    });
    expect(used.isUsed, isTrue);
  });
}
