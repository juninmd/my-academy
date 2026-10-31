import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/health_sync/health_sync_service.dart';

void main() {
  test('writes a date,weight CSV the server can read', () {
    final csv = buildWeightCsv([
      (day: DateTime(2026, 1, 5), kg: 80.456),
      (day: DateTime(2026, 10, 31), kg: 79),
    ]);
    expect(csv, 'date,weight\n2026-01-05,80.46\n2026-10-31,79.00\n');
  });

  test('writes only the header without weigh-ins', () {
    expect(buildWeightCsv(const []), 'date,weight\n');
  });
}
