import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/widgets/app_image.dart';

void main() {
  test('seeded exercise paths are bundled assets, not URLs', () {
    expect(AppImage.isRemote('assets/images/leg_press.gif'), isFalse);
    expect(AppImage.isRemote('https://cdn.example/leg.gif'), isTrue);
  });

  testWidgets('loads bundled paths through the asset bundle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(source: 'assets/images/leg_press.gif')),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('empty source shows the fallback', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppImage(source: '')));
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });
}
