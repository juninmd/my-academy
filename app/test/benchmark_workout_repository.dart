import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';

// Mock data generator
List<Map<String, dynamic>> generateMockData(int count) {
  return List.generate(count, (index) {
    return {
      'id': 'log_$index',
      'userId': 'user_1',
      'exerciseId': index % 100,
      'date': DateTime.now().toIso8601String(),
      'sets': [
        {'reps': 10, 'weight': 50, 'rpe': 8},
        {'reps': 8, 'weight': 55, 'rpe': 9},
        {'reps': 6, 'weight': 60, 'rpe': 10},
      ],
      'notes': 'Some notes for workout $index',
    };
  });
}

// Top-level function for compute
List<ExerciseLogEntity> parseAndMap(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString);
  return data
      .cast<Map<String, dynamic>>()
      .map(ExerciseLogEntity.fromJson)
      .toList();
}

void main() {
  test('Benchmark Full Offload (Decode + Map) in Compute', () async {
    const int count = 20000;
    final data = generateMockData(count);
    final jsonString = jsonEncode(data); // Prepare raw string

    final stopwatch = Stopwatch()..start();

    // Simulate what we would do: send string to isolate, get entities back
    final result = await compute(parseAndMap, jsonString);

    stopwatch.stop();
    debugPrint(
      'Full Offload (Decode + Map) of $count items took ${stopwatch.elapsedMilliseconds}ms',
    );
    expect(result.length, count);
  });
}
