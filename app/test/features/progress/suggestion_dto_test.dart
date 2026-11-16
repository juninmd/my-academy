import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/progress/data/models/suggestion_dto.dart';

void main() {
  test('maps a deload suggestion', () {
    final s = SuggestionDto.fromResponse({
      'suggestion': {
        'weight': 90,
        'reps': 5,
        'sets': 3,
        'deload': true,
        'reason': 'Stalled 3 sessions at 100: deload 10%.',
      },
    });
    expect(s?.weight, 90.0);
    expect(s?.deload, isTrue);
  });

  test('is null without a suggestion', () {
    expect(SuggestionDto.fromResponse({'suggestion': null}), isNull);
  });
}
