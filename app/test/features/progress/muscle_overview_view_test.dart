import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/progress/domain/entities/muscle_overview_entity.dart';
import 'package:my_academy/features/progress/presentation/widgets/muscle_overview_view.dart';

void main() {
  Widget host(MuscleOverviewEntity overview) => MaterialApp(
    home: Scaffold(body: MuscleOverviewView(overview: overview)),
  );

  testWidgets('shows recovery and balance messages', (tester) async {
    await tester.pumpWidget(
      host(
        MuscleOverviewEntity(
          muscles: [
            MuscleProgressEntity(
              muscle: 'chest',
              weightedSets: 3,
              lastTrained: DateTime(2026, 10, 29),
              state: MuscleState.recovering,
            ),
            const MuscleProgressEntity(
              muscle: 'quads',
              weightedSets: 0,
              lastTrained: null,
              state: MuscleState.untrained,
            ),
          ],
          balance: const [
            BalancePairEntity(
              key: 'biceps_triceps',
              label: 'Biceps vs triceps',
              left: 0.5,
              right: 1,
              ratio: 0.5,
              status: BalanceStatus.leftLow,
            ),
            BalancePairEntity(
              key: 'chest_back',
              label: 'Chest vs back',
              left: 2,
              right: 0,
              ratio: null,
              status: BalanceStatus.rightUntrained,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Peito'), findsOneWidget);
    expect(find.text('Recuperando'), findsOneWidget);
    expect(find.text('Quadríceps'), findsOneWidget);
    expect(find.text('Não treinado'), findsOneWidget);
    expect(find.text('3.0 séries'), findsOneWidget);
    expect(find.text('Pouco volume em bíceps'), findsOneWidget);
    expect(find.text('O lado costas não foi treinado'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('describes balanced, high and empty pairs', (tester) async {
    await tester.pumpWidget(
      host(
        const MuscleOverviewEntity(
          muscles: [],
          balance: [
            BalancePairEntity(
              key: 'a',
              label: 'Push vs pull',
              left: 1,
              right: 1,
              ratio: 1,
              status: BalanceStatus.balanced,
            ),
            BalancePairEntity(
              key: 'b',
              label: 'Push vs pull',
              left: 3,
              right: 1,
              ratio: 3,
              status: BalanceStatus.leftHigh,
            ),
            BalancePairEntity(
              key: 'c',
              label: 'Push vs pull',
              left: 0,
              right: 0,
              ratio: null,
              status: BalanceStatus.noData,
            ),
          ],
        ),
      ),
    );
    expect(find.text('Equilibrado'), findsOneWidget);
    expect(find.text('Muito volume em push'), findsOneWidget);
    expect(find.text('Sem treino nas últimas semanas'), findsOneWidget);
  });
}
