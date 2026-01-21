import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';

void main() {
  group('SetLogEntity', () {
    test('should have correct props', () {
      const setLog = SetLogEntity(reps: 10, weight: 100, rpe: 9);

      expect(setLog.reps, 10);
      expect(setLog.weight, 100);
      expect(setLog.rpe, 9);
      expect(setLog.props, [10, 100, 9]);
    });

    test('toJson and fromJson should work correctly', () {
      const setLog = SetLogEntity(reps: 10, weight: 100, rpe: 9);
      final json = setLog.toJson();
      final fromJson = SetLogEntity.fromJson(json);

      expect(fromJson, setLog);
    });
  });
}
