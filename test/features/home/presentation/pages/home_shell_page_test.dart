import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/home/presentation/pages/home_shell_page.dart';

@GenerateNiceMocks([MockSpec<StatefulNavigationShell>()])
import 'home_shell_page_test.mocks.dart';

void main() {
  late MockStatefulNavigationShell mockShell;

  setUp(() {
    mockShell = MockStatefulNavigationShell();
  });

  testWidgets('HomeShellPage displays navigation bar', (tester) async {
    when(mockShell.currentIndex).thenReturn(0);

    await tester.pumpWidget(
      MaterialApp(home: HomeShellPage(navigationShell: mockShell)),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Treinos'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);

    await tester.tap(find.text('Treinos'));
    verify(mockShell.goBranch(1, initialLocation: false));
  });
}
