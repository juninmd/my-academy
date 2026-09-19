import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/widgets/user_avatar.dart';

void main() {
  Future<void> pump(WidgetTester tester, UserAvatar avatar) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: avatar)));

  testWidgets('shows the name initial so a broken photo never leaves a blank', (
    tester,
  ) async {
    await pump(
      tester,
      const UserAvatar(name: 'ana', photoUrl: 'https://blocked.example/x.png'),
    );
    expect(find.text('A'), findsOneWidget);
  });

  test('never crashes on an empty or missing name', () {
    expect(const UserAvatar(name: '  ').initial, '?');
    expect(const UserAvatar(name: null).initial, '?');
    expect(const UserAvatar(name: 'Élio').initial, 'É');
  });
}
