import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/notifications/notification_service.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/fake_notification_service.dart';

ProviderContainer _container(FakeNotificationService fake) {
  SharedPreferences.setMockInitialValues({});
  return ProviderContainer(
    overrides: [notificationServiceProvider.overrideWithValue(fake)],
  );
}

void main() {
  test('enables reminder after permission is granted', () async {
    final fake = FakeNotificationService();
    final container = _container(fake);
    addTearDown(container.dispose);

    final ok = await container
        .read(settingsProvider.notifier)
        .setReminderEnabled(true);

    expect(ok, isTrue);
    expect(container.read(settingsProvider).reminderEnabled, isTrue);
    expect(fake.calls, ['permission', 'reminder:18:0']);
  });

  test('keeps reminder off when permission is denied', () async {
    final fake = FakeNotificationService(permissionGranted: false);
    final container = _container(fake);
    addTearDown(container.dispose);

    final ok = await container
        .read(settingsProvider.notifier)
        .setReminderEnabled(true);

    expect(ok, isFalse);
    expect(container.read(settingsProvider).reminderEnabled, isFalse);
    expect(fake.calls, ['permission']);
  });

  test('disabling reminder cancels it', () async {
    final fake = FakeNotificationService();
    final container = _container(fake);
    addTearDown(container.dispose);

    await container.read(settingsProvider.notifier).setReminderEnabled(false);

    expect(fake.calls, ['cancelReminder']);
    expect(container.read(settingsProvider).reminderEnabled, isFalse);
  });

  test('changing the time reschedules only when enabled', () async {
    final fake = FakeNotificationService();
    final container = _container(fake);
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);

    await notifier.setReminderTime(7, 15);
    expect(fake.calls, isEmpty);

    await notifier.setReminderEnabled(true);
    await notifier.setReminderTime(6, 45);

    expect(fake.calls.last, 'reminder:6:45');
    expect(container.read(settingsProvider).reminderHour, 6);
    expect(container.read(settingsProvider).reminderMinute, 45);
  });

  test('rest alert toggle respects permission', () async {
    final fake = FakeNotificationService(permissionGranted: false);
    final container = _container(fake);
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);

    expect(await notifier.setRestAlertEnabled(true), isFalse);
    expect(await notifier.setRestAlertEnabled(false), isTrue);
    expect(container.read(settingsProvider).restAlertEnabled, isFalse);
  });
}
