import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/notifications/notification_service.dart';

void main() {
  group('nextOccurrence', () {
    test('returns today when the time is still ahead', () {
      final now = DateTime(2026, 1, 10, 8, 30);
      expect(nextOccurrence(now, 18, 0), DateTime(2026, 1, 10, 18));
    });

    test('returns tomorrow when the time has passed', () {
      final now = DateTime(2026, 1, 10, 19);
      expect(nextOccurrence(now, 18, 0), DateTime(2026, 1, 11, 18));
    });

    test('returns tomorrow when the time is exactly now', () {
      final now = DateTime(2026, 1, 10, 18);
      expect(nextOccurrence(now, 18, 0), DateTime(2026, 1, 11, 18));
    });
  });
}
