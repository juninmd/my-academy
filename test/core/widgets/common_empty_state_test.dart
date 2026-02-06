import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/widgets/common_empty_state.dart';

void main() {
  testWidgets('CommonEmptyState displays title and message', (tester) async {
    const title = 'Test Title';
    const message = 'Test Message';

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CommonEmptyState(
          title: title,
          message: message,
        ),
      ),
    ));

    expect(find.text(title), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('CommonEmptyState displays icon when provided', (tester) async {
    const icon = Icons.star;

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CommonEmptyState(
          title: 'Title',
          message: 'Message',
          icon: icon,
        ),
      ),
    ));

    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('CommonEmptyState displays action button when provided', (tester) async {
    bool actionPressed = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CommonEmptyState(
          title: 'Title',
          message: 'Message',
          actionLabel: 'Click Me',
          onAction: () => actionPressed = true,
        ),
      ),
    ));

    expect(find.text('Click Me'), findsOneWidget);
    await tester.tap(find.text('Click Me'));
    expect(actionPressed, true);
  });
}
