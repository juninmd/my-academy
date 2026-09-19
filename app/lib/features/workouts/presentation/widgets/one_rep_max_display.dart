import 'package:flutter/material.dart';

class OneRepMaxDisplay extends StatelessWidget {
  const OneRepMaxDisplay({required this.weight, required this.reps, super.key});

  final double weight;
  final int reps;

  int get _estimated1RM {
    if (reps == 0 || weight == 0) return 0;
    if (reps == 1) return weight.round();
    // Epley formula
    return (weight * (1 + reps / 30)).round();
  }

  @override
  Widget build(BuildContext context) {
    final oneRm = _estimated1RM;
    if (oneRm == 0) return const SizedBox.shrink();

    return Tooltip(
      message: 'Estimativa de 1 Repetição Máxima (Fórmula de Epley)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              '1RM: ~$oneRm kg',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
