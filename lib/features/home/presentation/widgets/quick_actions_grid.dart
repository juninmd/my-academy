import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../workouts/presentation/widgets/plate_calculator_dialog.dart';
import '../../../workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';
import 'quick_timer_dialog.dart';
import 'body_weight_dialog.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle_outline,
        label: 'Criar Treino',
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/workouts/create'),
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'Histórico',
        color: Colors.deepPurple,
        onTap: () => context.push('/history'),
      ),
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: 'Exercícios',
        color: Colors.indigo,
        onTap: () => context.go('/home/exercises'),
      ),
      _QuickAction(
        icon: Icons.bar_chart,
        label: 'Análise',
        color: Colors.teal,
        onTap: () => context.push('/analytics'),
      ),
      _QuickAction(
        icon: Icons.calculate_outlined,
        label: 'Anilhas',
        color: Colors.blue,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const PlateCalculatorDialog(targetWeight: 0),
        ),
      ),
      _QuickAction(
        icon: Icons.fitness_center,
        label: '1RM',
        color: Colors.red,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const OneRepMaxCalculatorDialog(),
        ),
      ),
      _QuickAction(
        icon: Icons.timer_outlined,
        label: 'Timer',
        color: Colors.orange,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const QuickTimerDialog(),
        ),
      ),
      _QuickAction(
        icon: Icons.monitor_weight_outlined,
        label: 'Peso',
        color: Colors.purple,
        onTap: () => showDialog(
          context: context,
          builder: (context) => const BodyWeightDialog(),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesso Rápido',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: actions,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
