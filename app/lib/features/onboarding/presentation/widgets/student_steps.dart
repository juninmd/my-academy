import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';
import 'selection_card.dart';

class GoalStep extends ConsumerWidget {
  final VoidCallback onNext;

  const GoalStep({required this.onNext, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Qual é seu objetivo?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            title: 'Hipertrofia',
            subtitle: 'Ganhar massa muscular',
            icon: Icons.monitor_weight_outlined,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Hipertrofia');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Força',
            subtitle: 'Aumentar carga máxima',
            icon: Icons.fitness_center,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Força');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Resistência',
            subtitle: 'Melhorar condicionamento',
            icon: Icons.timer_outlined,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Resistência');
              onNext();
            },
          ),
        ],
      ),
    );
  }
}

class ExperienceStep extends ConsumerWidget {
  final VoidCallback onNext;

  const ExperienceStep({required this.onNext, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Qual seu nível de experiência?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            title: 'Iniciante',
            subtitle: 'Menos de 6 meses de treino',
            icon: Icons.person_outline,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setExperienceLevel('Iniciante');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Intermediário',
            subtitle: '6 meses a 2 anos',
            icon: Icons.person,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setExperienceLevel('Intermediário');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Avançado',
            subtitle: 'Mais de 2 anos de treino sério',
            icon: Icons.emoji_events_outlined,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setExperienceLevel('Avançado');
              onNext();
            },
          ),
        ],
      ),
    );
  }
}
