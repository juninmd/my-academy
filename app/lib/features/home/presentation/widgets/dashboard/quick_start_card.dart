import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/pulse_tokens.dart';
import '../../../../../core/widgets/pulse/pulse_card.dart';

/// Atalho para começar um treino livre quando não há sessão hoje.
class QuickStartCard extends StatelessWidget {
  const QuickStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return PulseCard(
      onTap: () => context.push('/workouts/create'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(PulseRadii.md),
            ),
            child: Icon(Icons.flash_on, color: scheme.onPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treino Rápido', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Sem planos? Inicie agora.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: scheme.primary),
        ],
      ),
    );
  }
}
