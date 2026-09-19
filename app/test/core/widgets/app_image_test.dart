import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/widgets/app_image.dart';

const _bucketImage =
    'https://br-se1.magaluobjects.com/fast-dl-cs/my-academy/exercises/v1/leg-press.webp';

void main() {
  test('seeded exercise images are URLs, bundled paths are not', () {
    expect(AppImage.isRemote(_bucketImage), isTrue);
    expect(AppImage.isRemote('assets/images/bg1.jpg'), isFalse);
  });

  testWidgets('loads bucket URLs through the network cache', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(source: _bucketImage)),
    );
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('loads bundled paths through the asset bundle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(source: 'assets/images/bg1.jpg')),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  // Rows seeded before the bucket move point at GIFs no longer bundled.
  testWidgets('a removed legacy asset shows the fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(source: 'assets/images/leg_press.gif')),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });

  testWidgets('empty source shows the fallback', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppImage(source: '')));
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });
}
