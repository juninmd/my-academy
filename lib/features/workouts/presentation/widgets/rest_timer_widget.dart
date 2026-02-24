import 'package:flutter/material.dart';

class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onAdd10Seconds,
    this.onAdd30Seconds,
    required this.onSkip,
    super.key,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback onAdd10Seconds;
  final VoidCallback? onAdd30Seconds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.timer, color: colorScheme.primary),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: onAdd10Seconds,
                  icon: const Text('+10'),
                  tooltip: '+10s',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                  ),
                ),
                if (onAdd30Seconds != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onAdd30Seconds,
                    icon: const Text('+30'),
                    tooltip: '+30s',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onSkip,
                  child: const Text('Pular'),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            color: colorScheme.primary,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
