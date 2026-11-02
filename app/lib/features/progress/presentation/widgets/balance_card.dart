import 'package:flutter/material.dart';

import '../../domain/entities/muscle_overview_entity.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.pair});

  final BalancePairEntity pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(pair.label),
        subtitle: Text(_messageOf(pair)),
        trailing: Text(
          pair.ratio == null ? '—' : pair.ratio!.toStringAsFixed(2),
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  static String _messageOf(BalancePairEntity pair) {
    return switch (pair.status) {
      BalanceStatus.noData => 'Sem treino nas últimas semanas',
      BalanceStatus.rightUntrained =>
        'O lado ${pair.label.split(' vs ').last.toLowerCase()} não foi treinado',
      BalanceStatus.leftLow =>
        'Pouco volume em ${pair.label.split(' vs ').first.toLowerCase()}',
      BalanceStatus.leftHigh =>
        'Muito volume em ${pair.label.split(' vs ').first.toLowerCase()}',
      BalanceStatus.balanced => 'Equilibrado',
    };
  }
}
