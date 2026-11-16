import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/pulse/pulse_card.dart';

import '../../../workouts/presentation/widgets/plate_calculator_dialog.dart';
import '../../../workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';
import 'quick_timer_dialog.dart';
import 'body_weight_dialog.dart';
import 'quick_note_dialog.dart';
import 'quick_action_tile.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final effort = scheme.secondary;
    final actions = [
      QuickActionTile(
        icon: Icons.add_circle_outline,
        label: 'Criar Treino',
        color: accent,
        onTap: () => context.push('/workouts/create'),
      ),
      QuickActionTile(
        icon: Icons.history,
        label: 'Histórico',
        color: scheme.onSurface,
        onTap: () => context.push('/history'),
      ),
      QuickActionTile(
        icon: Icons.menu_book_outlined,
        label: 'Exercícios',
        color: scheme.onSurface,
        onTap: () => context.go('/home/exercises'),
      ),
      QuickActionTile(
        icon: Icons.bar_chart,
        label: 'Análise',
        color: accent,
        onTap: () => context.go('/analytics'),
      ),
      QuickActionTile(
        icon: Icons.calculate_outlined,
        label: 'Anilhas',
        color: scheme.onSurface,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const PlateCalculatorDialog(targetWeight: 0),
        ),
      ),
      QuickActionTile(
        icon: Icons.fitness_center,
        label: '1RM',
        color: effort,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const OneRepMaxCalculatorDialog(),
        ),
      ),
      QuickActionTile(
        icon: Icons.timer_outlined,
        label: 'Timer',
        color: scheme.onSurface,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const QuickTimerDialog(),
        ),
      ),
      QuickActionTile(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        color: scheme.onSurface,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const BodyWeightDialog(),
        ),
      ),
      QuickActionTile(
        icon: Icons.edit_note,
        label: 'Diário',
        color: effort,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const QuickNoteDialog(),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PulseSectionLabel('Acesso Rápido'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: actions,
        ),
      ],
    );
  }
}
