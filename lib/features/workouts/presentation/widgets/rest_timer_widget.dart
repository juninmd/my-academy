import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final isUrgent = remainingSeconds <= 10 && remainingSeconds > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                  color: isUrgent ? Colors.redAccent : colorScheme.primary,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${remainingSeconds}s',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: isUrgent ? Colors.redAccent : colorScheme.onSurface,
                    ),
                  )
                  .animate(target: isUrgent ? 1 : 0)
                  .shake(hz: 4, curve: Curves.easeInOut),
                  const Text(
                    'Descanso',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Vamos!'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAdd10Seconds,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('+10 segundos'),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutBack, duration: 400.ms);
  }
}
