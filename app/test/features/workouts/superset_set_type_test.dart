import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/data/models/set_log_dto.dart';
import 'package:my_academy/features/workouts/data/models/workout_dto.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';

void main() {
  test('reads and writes the rest-pause set type', () {
    final dto = SetLogDto.fromJson({
      'reps': 6,
      'weight': 60,
      'type': 'restpause',
    });
    expect(dto.type, SetType.restpause);
    expect(dto.toJson()['type'], 'restpause');
  });

  test('falls back to normal for an unknown set type', () {
    final dto = SetLogDto.fromJson({'reps': 6, 'weight': 60, 'type': 'mega'});
    expect(dto.type, SetType.normal);
  });

  test('keeps the superset label through the workout DTO and entity', () {
    final dto = WorkoutDto.fromJson({
      'exerciseId': 3,
      'supersetGroup': 'A',
      'workoutSeries': [],
    });
    expect(dto.supersetGroup, 'A');
    expect(dto.toEntity().supersetGroup, 'A');
    expect(
      WorkoutDto.fromEntity(dto.toEntity()).toJson()['supersetGroup'],
      'A',
    );
    expect(
      WorkoutDto.fromJson({'exerciseId': 3})
          .toJson()
          .containsKey('supersetGroup'),
      isFalse,
    );
  });
}
