import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';

class CommitmentStep extends ConsumerWidget {
  final VoidCallback onFinish;

  const CommitmentStep({required this.onFinish, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quantas vezes por semana você pretende treinar?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${settings.weeklyWorkoutGoal} dias',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: settings.weeklyWorkoutGoal.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: settings.weeklyWorkoutGoal.toString(),
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .setWeeklyGoal(value.round());
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onFinish,
              child: const Text('Concluir Configuração'),
            ),
          ),
        ],
      ),
    );
  }
}
