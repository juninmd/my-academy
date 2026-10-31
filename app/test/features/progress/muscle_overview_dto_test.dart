import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/progress/data/models/muscle_overview_dto.dart';
import 'package:my_academy/features/progress/domain/entities/muscle_overview_entity.dart';

void main() {
  test('maps muscles, recovery and balance', () {
    final overview = MuscleOverviewDto.fromJson({
      'days': 90,
      'muscles': [
        {
          'muscle': 'chest',
          'weightedSets': 3,
          'lastTrained': '2026-10-29',
          'state': 'recovering',
        },
        {
          'muscle': 'quads',
          'weightedSets': 0,
          'lastTrained': null,
          'state': 'untrained',
        },
      ],
      'balance': [
        {
          'key': 'push_pull',
          'label': 'Push vs pull',
          'left': 4,
          'right': 1.5,
          'ratio': 2.67,
          'status': 'left_high',
        },
        {
          'key': 'quads_hamstrings',
          'label': 'Quads vs hamstrings',
          'left': 0,
          'right': 0,
          'ratio': null,
          'status': 'no_data',
        },
      ],
    });

    expect(overview.muscles.first.weightedSets, 3.0);
    expect(overview.muscles.first.state, MuscleState.recovering);
    expect(overview.muscles.first.lastTrained, DateTime.parse('2026-10-29'));
    expect(overview.muscles.last.lastTrained, isNull);
    expect(overview.balance.first.status, BalanceStatus.leftHigh);
    expect(overview.balance.first.ratio, 2.67);
    expect(overview.balance.last.ratio, isNull);
    expect(overview.balance.last.status, BalanceStatus.noData);
  });

  test('defaults unknown states and an empty payload', () {
    final overview = MuscleOverviewDto.fromJson({
      'muscles': [
        {
          'muscle': 'calves',
          'weightedSets': 1,
          'lastTrained': null,
          'state': 'weird',
        },
      ],
      'balance': [
        {
          'key': 'x',
          'label': 'X',
          'left': 1,
          'right': 1,
          'ratio': 1,
          'status': 'weird',
        },
      ],
    });
    expect(overview.muscles.single.state, MuscleState.untrained);
    expect(overview.balance.single.status, BalanceStatus.noData);

    final empty = MuscleOverviewDto.fromJson({});
    expect(empty.muscles, isEmpty);
    expect(empty.balance, isEmpty);
  });
}
