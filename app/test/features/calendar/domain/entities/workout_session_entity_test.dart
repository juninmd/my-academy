import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/calendar/domain/entities/workout_session_entity.dart';

void main() {
  group('WorkoutSessionEntity', () {
    test('should have correct props', () {
      final date = DateTime.now();
      final session = WorkoutSessionEntity(
        id: 1,
        workoutGroupId: 10,
        date: date,
        checked: true,
        userId: 'user1',
      );

      expect(session.id, 1);
      expect(session.workoutGroupId, 10);
      expect(session.date, date);
      expect(session.checked, true);
      expect(session.userId, 'user1');
      expect(session.props, [1, 10, date, true, 'user1', null]);
    });
  });
}
