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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark aesthetic for timer
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
                Text(
                  '$remainingSeconds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Text Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descansando',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  remainingSeconds > 0 ? 'Respire fundo' : 'Vamos!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimerButton(
                label: '+10s',
                onTap: onAdd10Seconds,
                color: Colors.white.withValues(alpha: 0.1),
                textColor: Colors.white,
              ),
              if (onAdd30Seconds != null) ...[
                const SizedBox(width: 8),
                _TimerButton(
                  label: '+30s',
                  onTap: onAdd30Seconds!,
                  color: Colors.white.withValues(alpha: 0.1),
                  textColor: Colors.white,
                ),
              ],
              const SizedBox(width: 8),
              _TimerIconButton(
                icon: Icons.skip_next_rounded,
                onTap: onSkip,
                color: colorScheme.primary,
                iconColor: colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerIconButton extends StatelessWidget {
  const _TimerIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
