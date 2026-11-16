import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// One weigh-in: its calendar day and the weight in kilograms.
typedef WeighIn = ({DateTime day, double kg});

/// Health Connect's default read window without the history permission.
const healthReadWindow = Duration(days: 30);

/// Builds the `date,weight` CSV that `POST /imports/body-weight` reads.
String buildWeightCsv(Iterable<WeighIn> weighIns) {
  String two(int n) => n.toString().padLeft(2, '0');
  final buffer = StringBuffer('date,weight\n');
  for (final w in weighIns) {
    final d = w.day;
    buffer.writeln(
      '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)},'
      '${w.kg.toStringAsFixed(2)}',
    );
  }
  return buffer.toString();
}

/// Reads body weight from Health Connect (Android only). Apple Health is not wired here.
class HealthSyncService {
  HealthSyncService({Health? health}) : _health = health ?? Health();

  final Health _health;

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> requestWeightAccess() async {
    await _health.configure();
    return _health.requestAuthorization(
      [HealthDataType.WEIGHT],
      permissions: [HealthDataAccess.READ],
    );
  }

  /// Weigh-ins from the last [healthReadWindow], in kilograms.
  Future<List<WeighIn>> readWeighIns({DateTime? now}) async {
    final end = now ?? DateTime.now();
    await _health.configure();
    final points = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WEIGHT],
      preferredUnits: {HealthDataType.WEIGHT: HealthDataUnit.KILOGRAM},
      startTime: end.subtract(healthReadWindow),
      endTime: end,
    );
    final weighIns = <WeighIn>[];
    for (final point in points) {
      final value = point.value;
      if (value is! NumericHealthValue) continue;
      final local = point.dateFrom.toLocal();
      weighIns.add((
        day: DateTime(local.year, local.month, local.day),
        kg: value.numericValue.toDouble(),
      ));
    }
    return weighIns;
  }
}
