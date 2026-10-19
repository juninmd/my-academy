import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/notifications/notification_service.dart';
import 'package:my_academy/features/profile/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/fake_notification_service.dart';

Future<FakeNotificationService> _pump(
  WidgetTester tester, {
  bool permissionGranted = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final fake = FakeNotificationService(permissionGranted: permissionGranted);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [notificationServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: SettingsPage()),
    ),
  );
  return fake;
}

void main() {
  testWidgets('toggling the reminder schedules it', (tester) async {
    final fake = await _pump(tester);

    await tester.tap(find.text('Lembrete de treino'));
    await tester.pumpAndSettle();

    expect(fake.calls, contains('reminder:18:0'));
  });

  testWidgets('shows a hint when permission is denied', (tester) async {
    await _pump(tester, permissionGranted: false);

    await tester.tap(find.text('Lembrete de treino'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Permita as notificações'), findsOneWidget);
  });

  testWidgets('theme selector updates the setting', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    final selected = tester.widget<SegmentedButton<ThemeMode>>(
      find.byType(SegmentedButton<ThemeMode>),
    );
    expect(selected.selected, {ThemeMode.dark});
  });
}
