import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/hooks/use_rest_timer.dart';

import '../../../../core/notifications/fake_notification_service.dart';

void main() {
  testWidgets('schedules, extends and cancels the rest alert', (tester) async {
    final fake = FakeNotificationService();
    late RestTimerState timer;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            timer = useRestTimer(notifications: fake);
            return const SizedBox();
          },
        ),
      ),
    );

    timer.start(60);
    timer.extend(30);
    timer.stop();
    await tester.pump();

    expect(fake.calls, ['cancelRest', 'rest:60', 'rest:90', 'cancelRest']);
    expect(timer.remaining.value, 90);
    expect(timer.isActive.value, isFalse);
  });

  testWidgets('works without a notification service', (tester) async {
    late RestTimerState timer;
    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            timer = useRestTimer();
            return const SizedBox();
          },
        ),
      ),
    );

    timer.start(10);
    await tester.pump();
    expect(timer.isActive.value, isTrue);
    timer.stop();
    await tester.pump();
  });
}
