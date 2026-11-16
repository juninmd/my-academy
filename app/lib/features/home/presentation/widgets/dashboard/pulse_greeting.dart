import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/pulse_tokens.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../../auth/domain/entities/user_entity.dart';

/// Cabeçalho do Hoje: data, saudação, sequência e avatar.
class PulseGreeting extends StatelessWidget {
  const PulseGreeting({required this.user, this.streak, super.key});

  final UserEntity? user;
  final int? streak;

  static String greetingFor(int hour) {
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final name = user?.name?.split(' ').first ?? 'Atleta';
    final date = DateFormat("EEEE, d 'de' MMM", 'pt_BR').format(now);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date[0].toUpperCase()}${date.substring(1)}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${greetingFor(now.hour)}, $name.',
                style: theme.textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (streak != null) ...[
          _StreakChip(streak: streak!),
          const SizedBox(width: 10),
        ],
        Semantics(
          button: true,
          label: 'Abrir perfil',
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: UserAvatar(
              name: user?.name,
              photoUrl: user?.photoUrl,
              radius: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Sequência de $streak dias',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(PulseRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 16,
              color: scheme.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
