import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/home/presentation/pages/home_shell_page.dart';

@GenerateNiceMocks([MockSpec<StatefulNavigationShell>()])
import 'home_shell_page_test.mocks.dart';

class _DummyState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  late MockStatefulNavigationShell mockShell;

  setUp(() {
    mockShell = MockStatefulNavigationShell();
  });

  testWidgets('HomeShellPage displays navigation bar', (tester) async {
    when(mockShell.currentIndex).thenReturn(0);

    // MockStatefulNavigationShell causes a NoSuchMethodError when pumped directly
    // because its framework lifecycle methods are mocked (and null by default).
    // Instead of using the mock shell, we will use a test widget that uses
    // a real widget to represent the shell. But to test what we want, we only
    // care about the bottom navigation bar working.

    // Instead of using mockShell in HomeShellPage directly for pump,
    // let's test a slightly refactored scenario, or just test the
    // navigation behavior directly.
    when(mockShell.key).thenReturn(null);
    when(
      mockShell.createElement(),
    ).thenAnswer((_) => StatefulElement(mockShell));
    when(mockShell.createState()).thenAnswer((_) => _DummyState());

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
