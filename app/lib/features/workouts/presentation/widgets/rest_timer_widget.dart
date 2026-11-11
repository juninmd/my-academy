import 'package:flutter/material.dart';

import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pulse_ring.dart';
import 'rest_timer_button.dart';

/// Painel de descanso do PULSE: anel grande em contagem regressiva.
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

  static String format(int s) =>
      s < 60 ? '$s' : '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    const fg = PulseColors.chalk;
    final panel = Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: PulseColors.carbon,
        borderRadius: BorderRadius.circular(PulseRadii.xl),
        border: Border.all(color: PulseColors.graphite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DESCANSO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: PulseColors.mist,
            ),
          ),
          const SizedBox(height: 12),
          PulseRing(
            value: progress,
            size: 168,
            stroke: 10,
            color: PulseColors.volt,
            trackColor: PulseColors.graphite,
            duration: const Duration(milliseconds: 950),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  format(remainingSeconds),
                  style: theme.textTheme.displayMedium?.copyWith(color: fg),
                ),
                Text(
                  remainingSeconds > 0 ? 'Respire fundo' : 'Vamos!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PulseColors.mist,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RestTimerButton(label: '+10s', onTap: onAdd10Seconds),
              ),
              if (onAdd30Seconds != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: RestTimerButton(label: '+30s', onTap: onAdd30Seconds!),
                ),
              ],
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: RestTimerButton(
                  label: 'Pular',
                  icon: Icons.skip_next_rounded,
                  onTap: onSkip,
                  primary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PulseMotion.page,
      curve: PulseMotion.spring,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 40 * (1 - t)),
          child: child,
        ),
      ),
      child: panel,
    );
  }
}
