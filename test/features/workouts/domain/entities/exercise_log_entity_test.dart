import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';

void main() {
  group('ExerciseLogEntity', () {
    test('should have correct props', () {
      final date = DateTime.now();
      const sets = [SetLogEntity(reps: 10, weight: 100)];
      final log = ExerciseLogEntity(
        id: '1',
        userId: 'user1',
        exerciseId: 10,
        date: date,
        sets: sets,
        notes: 'Great workout',
      );

      expect(log.id, '1');
      expect(log.userId, 'user1');
      expect(log.exerciseId, 10);
      expect(log.date, date);
      expect(log.sets, sets);
      expect(log.notes, 'Great workout');
      expect(log.props, ['1', 'user1', 10, date, sets, 'Great workout']);
    });

    test('toJson and fromJson should work correctly', () {
      final date = DateTime.now();
      // Truncate to milliseconds to avoid issues with precision during JSON serialization if using ISO8601
      // However, Equatable and props should handle it if the object is reconstructed.
      // But standard DateTime comparison can be tricky with microsecond precision loss in JSON.
      // We'll depend on toIso8601String which might lose precision depending on implementation,
      // but usually preserves it. Let's see.

      const sets = [SetLogEntity(reps: 10, weight: 100)];
      final log = ExerciseLogEntity(
        id: '1',
        userId: 'user1',
        exerciseId: 10,
        date: date,
        sets: sets,
        notes: 'Great workout',
      );

      final json = log.toJson();
      final fromJson = ExerciseLogEntity.fromJson(json);

      // Compare individual fields to avoid DateTime precision issues if any
      expect(fromJson.id, log.id);
      expect(fromJson.userId, log.userId);
      expect(fromJson.exerciseId, log.exerciseId);
      // Allow small difference for date time string conversion
      expect(
        fromJson.date.difference(log.date).inMilliseconds.abs(),
        lessThan(2),
      );
      expect(fromJson.sets, log.sets);
      expect(fromJson.notes, log.notes);
    });
  });
}
