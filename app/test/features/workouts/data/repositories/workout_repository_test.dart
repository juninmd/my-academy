import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/workouts/data/repositories/workout_repository_impl.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';

import 'workout_repository_test.mocks.dart';

import 'package:hive_flutter/hive_flutter.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late WorkoutRepositoryImpl repository;

  setUpAll(() async {
    Hive.init('test_hive_dir');
    await Hive.openBox('workouts');
    await Hive.openBox('exercise_logs');
  });

  setUp(() {
    mockApiClient = MockApiClient();
    repository = WorkoutRepositoryImpl(mockApiClient);
  });

  group('getWorkoutGroups', () {
    test('should return list of workout groups when successful', () async {
      final mockData = [
        {
          'id': 1,
          'name': 'Group 1',
          'image': 'img.jpg',
          'userId': 'user1',
          'workouts': [],
        },
      ];

      when(
        mockApiClient.get('workouts-groups/user/user1'),
      ).thenAnswer((_) async => mockData);

      final result = await repository.getWorkoutGroups('user1');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) {
        expect(r.length, 1);
        expect(r[0].id, 1);
        expect(r[0].name, 'Group 1');
      });
    });

    test('should return failure when exception', () async {
      when(mockApiClient.get(any)).thenThrow(Exception('Error'));

      final result = await repository.getWorkoutGroups('user_doesnt_exist');

      expect(result.isLeft(), true);
    });
  });

  group('getExercises', () {
    test('should return list of exercises when successful', () async {
      final mockData = [
        {
          'id': 1,
          'name': 'Exercise 1',
          'image': 'img.jpg',
          'description': 'desc',
        },
      ];

      when(mockApiClient.get('exercises')).thenAnswer((_) async => mockData);

      final result = await repository.getExercises();

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) {
        expect(r.length, 1);
        expect(r[0].id, 1);
      });
    });
  });

  group('getExerciseLogs', () {
    test('should return logs', () async {
      final mockData = [
        {
          'id': 1,
          'userId': 'u1',
          'exerciseId': 10,
          'date': DateTime.now().toIso8601String(),
          'sets': [],
        },
      ];
      when(
        mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer((_) async => mockData);

      final result = await repository.getExerciseLogs('u1', 10);
      expect(result.isRight(), true);
    });
  });

  group('saveExerciseLog', () {
    test('should return saved log', () async {
      final log = ExerciseLogEntity(
        userId: 'u1',
        exerciseId: 10,
        date: DateTime.now(),
        sets: const [],
      );
      final mockResponse = {
        'id': 1,
        'userId': 'u1',
        'exerciseId': 10,
        'date': log.date.toIso8601String(),
        'sets': [],
      };

      when(
        mockApiClient.post('exercise-logs', data: anyNamed('data')),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.saveExerciseLog(log);
      expect(result.isRight(), true);
    });
  });
}
