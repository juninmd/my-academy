import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';

// Mock data generator
List<ExerciseLogEntity> generateLogs(int count) {
  final now = DateTime.now();
  return List.generate(count, (index) {
    return ExerciseLogEntity(
      exerciseId: 1,
      date: now.subtract(
        Duration(hours: index % (24 * 14)),
      ), // Spread over 2 weeks, with hours
      sets: [
        const SetLogEntity(reps: 10, weight: 100),
        const SetLogEntity(reps: 8, weight: 110),
      ],
      userId: 'user1',
    );
  });
}

class VolumeCalculationBenchmark extends BenchmarkBase {
  final List<ExerciseLogEntity> logs;
  final DateTime today;

  VolumeCalculationBenchmark(this.logs)
    : today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      super('Baseline');

  @override
  void run() {
    final Map<int, double> volumePerDay = {};
    for (var log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (logDate.isAfter(today.subtract(const Duration(days: 7))) &&
          logDate.isBefore(today.add(const Duration(days: 1)))) {
        final dayIndex = 6 - today.difference(logDate).inDays;
        if (dayIndex >= 0 && dayIndex < 7) {
          final volume = log.sets.fold<double>(
            0,
            (sum, set) => sum + (set.weight * set.reps),
          );
          volumePerDay[dayIndex] = (volumePerDay[dayIndex] ?? 0) + volume;
        }
      }
    }
  }
}

class OptimizedVolumeCalculationBenchmark extends BenchmarkBase {
  final List<ExerciseLogEntity> logs;
  final DateTime today;
  late final DateTime lowerBound;
  late final DateTime upperBound;

  OptimizedVolumeCalculationBenchmark(this.logs)
    : today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      super('Optimized') {
    lowerBound = today.subtract(const Duration(days: 6));
    upperBound = today.add(const Duration(days: 1));
  }

  @override
  void run() {
    final Map<int, double> volumePerDay = {};
    for (var log in logs) {
      if (log.date.compareTo(lowerBound) >= 0 &&
          log.date.isBefore(upperBound)) {
        final dayIndex = log.date.difference(lowerBound).inDays;
        if (dayIndex >= 0 && dayIndex < 7) {
          final volume = log.sets.fold<double>(
            0,
            (sum, set) => sum + (set.weight * set.reps),
          );
          volumePerDay[dayIndex] = (volumePerDay[dayIndex] ?? 0) + volume;
        }
      }
    }
  }
}

void main() {
  final logs = generateLogs(10000); // 10k logs
  debugPrint('Running benchmarks with 10,000 logs...');
  VolumeCalculationBenchmark(logs).report();
  OptimizedVolumeCalculationBenchmark(logs).report();
}
