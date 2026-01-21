import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/session_log_entity.dart';

void main() {
  group('SetLogState', () {
    test('should hold correct values', () {
      final log = SetLogState(
        actualReps: 10,
        actualWeight: 50,
        rpe: 8,
        isCompleted: true,
      );

      expect(log.actualReps, 10);
      expect(log.actualWeight, 50);
      expect(log.rpe, 8);
      expect(log.isCompleted, true);
    });
  });

  group('ExerciseSessionLog', () {
    test('should hold correct values', () {
      final setLogs = {
        0: SetLogState(actualReps: 10, actualWeight: 20),
      };
      final sessionLog = ExerciseSessionLog(
        exerciseId: 1,
        exerciseName: 'Squat',
        setLogs: setLogs,
        notes: 'Good form',
      );

      expect(sessionLog.exerciseId, 1);
      expect(sessionLog.exerciseName, 'Squat');
      expect(sessionLog.setLogs, setLogs);
      expect(sessionLog.notes, 'Good form');
    });
  });
}
