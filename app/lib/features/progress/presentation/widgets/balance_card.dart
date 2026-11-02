import 'package:flutter/material.dart';

import '../../domain/entities/muscle_overview_entity.dart';

/// Portuguese names for the balance pairs the API sends by key.
const _pairNames = {
  'push_pull': ('Empurrar', 'Puxar'),
  'chest_back': ('Peito', 'Costas'),
  'quads_hamstrings': ('Quadríceps', 'Posteriores'),
  'biceps_triceps': ('Bíceps', 'Tríceps'),
};

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.pair});

  final BalancePairEntity pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = _pairNames[pair.key];
    return Card(
      child: ListTile(
        title: Text(names == null ? pair.label : '${names.$1} vs ${names.$2}'),
        subtitle: Text(_messageOf(pair, names)),
        trailing: Text(
          pair.ratio == null ? '—' : pair.ratio!.toStringAsFixed(2),
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  static String _messageOf(BalancePairEntity pair, (String, String)? names) {
    final left = names?.$1 ?? pair.label.split(' vs ').first;
    final right = names?.$2 ?? pair.label.split(' vs ').last;
    return switch (pair.status) {
      BalanceStatus.noData => 'Sem treino nas últimas semanas',
      BalanceStatus.rightUntrained =>
        'O lado ${right.toLowerCase()} não foi treinado',
      BalanceStatus.leftLow => 'Pouco volume em ${left.toLowerCase()}',
      BalanceStatus.leftHigh => 'Muito volume em ${left.toLowerCase()}',
      BalanceStatus.balanced => 'Equilibrado',
    };
  }
}
