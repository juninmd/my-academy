import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/timer_notifier.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  group('TimerNotifier', () {
    late TimerNotifier notifier;

    setUp(() {
      notifier = TimerNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial value is 0', () {
      expect(notifier.value, 0);
    });

    test('start increments value over time', () {
      fakeAsync((async) {
        notifier.start();
        expect(notifier.value, 0);

        async.elapse(const Duration(seconds: 1));
        expect(notifier.value, 1);

        async.elapse(const Duration(seconds: 4));
        expect(notifier.value, 5);

        notifier.stop();
      });
    });

    test('stop pauses the timer', () {
      fakeAsync((async) {
        notifier.start();
        async.elapse(const Duration(seconds: 2));
        expect(notifier.value, 2);

        notifier.stop();
        async.elapse(const Duration(seconds: 2));
        expect(notifier.value, 2);
      });
    });
  });
}
