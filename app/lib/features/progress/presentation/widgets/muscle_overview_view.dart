import 'package:flutter/material.dart';

import '../../domain/entities/muscle_overview_entity.dart';
import 'balance_card.dart';
import 'muscle_name.dart';

/// Recovery list and balance cards for the last 90 days.
class MuscleOverviewView extends StatelessWidget {
  const MuscleOverviewView({super.key, required this.overview});

  final MuscleOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Equilíbrio', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final pair in overview.balance) BalanceCard(pair: pair),
        const SizedBox(height: 24),
        Text('Recuperação', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final muscle in overview.muscles)
          ListTile(
            key: ValueKey('muscle-${muscle.muscle}'),
            title: Text(muscleName(muscle.muscle)),
            subtitle: Text(_stateLabel(muscle.state)),
            trailing: Text('${muscle.weightedSets.toStringAsFixed(1)} séries'),
          ),
      ],
    );
  }

  static String _stateLabel(MuscleState state) {
    return switch (state) {
      MuscleState.untrained => 'Não treinado',
      MuscleState.recovering => 'Recuperando',
      MuscleState.recovered => 'Recuperado',
    };
  }
}
