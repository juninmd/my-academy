import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/home/presentation/pages/home_shell_page.dart';
import 'package:my_academy/features/home/presentation/widgets/pulse_action_sheet.dart';
import 'package:my_academy/features/home/presentation/widgets/pulse_nav_bar.dart';

@GenerateNiceMocks([MockSpec<StatefulNavigationShell>()])
import 'home_shell_page_test.mocks.dart';

class _DummyState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.role);
  final String role;

  @override
  Future<UserEntity?> build() async =>
      UserEntity(id: 'u1', email: 'u1@myacademy.dev', role: role);
}

void main() {
  late MockStatefulNavigationShell shell;

  setUp(() {
    shell = MockStatefulNavigationShell();
    when(shell.currentIndex).thenReturn(0);
    when(shell.createElement()).thenAnswer((_) => StatefulElement(shell));
    when(shell.createState()).thenAnswer((_) => _DummyState());
  });

  Future<void> pumpShell(WidgetTester tester, String role, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => _FakeAuthNotifier(role)),
        ],
        child: MaterialApp(home: HomeShellPage(navigationShell: shell)),
      ),
    );
    await tester.pump();
  }

  testWidgets('student on a phone gets the Pulse bar with training tabs', (
    tester,
  ) async {
    await pumpShell(tester, 'STUDENT', const Size(400, 800));

    expect(find.byType(PulseNavBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
    expect(find.text('Calendário'), findsNothing);
    expect(find.text('Academia'), findsNothing);

    await tester.tap(find.text('Treinos'));
    verify(shell.goBranch(1, initialLocation: false));

    await tester.tap(find.text('Hoje'));
    verify(shell.goBranch(0, initialLocation: true));
  });

  testWidgets('the Pulse button opens every quick action', (tester) async {
    await pumpShell(tester, 'STUDENT', const Size(400, 900));

    await tester.tap(find.byTooltip('Ações rápidas'));
    await tester.pumpAndSettle();

    expect(find.byType(PulseActionSheet), findsOneWidget);
    for (final action in pulseActions) {
      expect(find.text(action.label), findsOneWidget);
    }
  });

  testWidgets('owner phone bar has the gym, workouts and profile', (
    tester,
  ) async {
    await pumpShell(tester, 'OWNER', const Size(400, 800));

    expect(find.text('Academia'), findsOneWidget);
    expect(find.text('Você'), findsOneWidget);
    expect(find.text('Hoje'), findsNothing);
  });

  testWidgets('gym owner on desktop gets an extended rail led by the gym', (
    tester,
  ) async {
    await pumpShell(tester, 'OWNER', const Size(1300, 900));

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    expect(find.byType(PulseNavBar), findsNothing);
    expect(find.byType(PulseButton), findsOneWidget);
    expect(find.text('Academia'), findsOneWidget);
    expect(find.text('Progresso'), findsNothing);
  });

  testWidgets('personal trainer sees the students tab', (tester) async {
    await pumpShell(tester, 'PERSONAL', const Size(900, 800));

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    await tester.tap(find.text('Alunos'));
    verify(shell.goBranch(5, initialLocation: false));
  });
}
