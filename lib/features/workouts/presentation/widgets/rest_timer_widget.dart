import 'package:flutter/material.dart';

class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onAdd10Seconds,
    required this.onSkip,
    super.key,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback onAdd10Seconds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descanso',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${remainingSeconds}s',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: onAdd10Seconds,
                icon: const Icon(Icons.add),
                tooltip: '+10s',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onSkip,
                icon: const Icon(Icons.skip_next),
                label: const Text('Pular'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
