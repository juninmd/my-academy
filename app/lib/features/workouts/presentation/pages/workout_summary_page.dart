import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/session_log_entity.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/shareable_workout_card.dart';

class WorkoutSummaryPage extends HookWidget {
  const WorkoutSummaryPage({
    required this.duration,
    required this.sessionLogs,
    this.newRecords = const [],
    super.key,
  });

  final Duration duration;
  final Map<int, ExerciseSessionLog> sessionLogs;
  final List<String> newRecords;

  String _getWeightEquivalence(int weightKg) {
    if (weightKg < 100) return 'um Lobo Grande 🐺';
    if (weightKg < 500) return 'um Urso Pardo 🐻';
    if (weightKg < 1000) return 'um Piano de Cauda 🎹';
    if (weightKg < 2000) return 'um Carro Compacto 🚗';
    if (weightKg < 5000) return 'um Elefante 🐘';
    if (weightKg < 10000) return 'um T-Rex 🦖';
    return 'um Ônibus Espacial 🚀';
  }

  @override
  Widget build(BuildContext context) {
    final intensity = useState(3.0);
    int totalSets = 0;
    int totalWeight = 0;

    for (final log in sessionLogs.values) {
      for (final set in log.setLogs.values) {
        if (set.isCompleted) {
          totalSets++;
          totalWeight += set.actualWeight * set.actualReps;
        }
      }
    }

    return Scaffold(
      body: ConfettiOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Shareable Card Section
                ShareableWorkoutCard(
                  duration: duration,
                  totalWeight: totalWeight,
                  totalSets: totalSets,
                  newRecords: newRecords,
                ),
                const SizedBox(height: 48),

                // Intensity Slider
                Text(
                  'Como foi o treino?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('😎', style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Slider(
                              value: intensity.value,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label:
                                  [
                                    'Fácil',
                                    'Moderado',
                                    'Bom',
                                    'Intenso',
                                    'Insano',
                                  ][intensity.value.toInt() - 1],
                              onChanged: (v) => intensity.value = v,
                            ),
                          ),
                          const Text('🥵', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Text(
                        [
                          'Fácil',
                          'Moderado',
                          'Bom',
                          'Intenso',
                          'Insano',
                        ][intensity.value.toInt() - 1],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final durationStr = _formatDuration(duration);
                            final volumeStr = (totalWeight / 1000)
                                .toStringAsFixed(1);
                            String text =
                                '🔥 Treino Concluído no MyAcademy!\n\n';
                            text += '⏱️ Duração: $durationStr\n';
                            text += '💪 Volume Total: ${volumeStr}ton\n';
                            text +=
                                '🏋️ Equivalente a: ${_getWeightEquivalence(totalWeight)}\n';

                            if (newRecords.isNotEmpty) {
                              text += '\n🏆 Recordes:\n';
                              for (final rec in newRecords) {
                                text += '- $rec\n';
                              }
                            }
                            text += '\n#MyAcademy #Fitness #NoPainNoGain';
                            // ignore: deprecated_member_use
                            await Share.share(text);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Concluir',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}
