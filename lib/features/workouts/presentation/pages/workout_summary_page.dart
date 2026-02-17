import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/session_log_entity.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber,
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Treino Concluído!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                'Ótimo trabalho hoje.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              if (newRecords.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'Recordes Quebrados! 🏆',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0, delay: 500.ms).fadeIn(),
                const SizedBox(height: 16),
                ...newRecords.map(
                  (record) => Card(
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              record,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().scale(delay: 600.ms),
                ),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Você levantou o equivalente a',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWeightEquivalence(totalWeight),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().scale(delay: 600.ms),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    label: 'Tempo',
                    value: _formatDuration(duration),
                    icon: Icons.timer_outlined,
                    color: Colors.blue,
                  ),
                  _SummaryStat(
                    label: 'Volume',
                    value: '${(totalWeight / 1000).toStringAsFixed(1)}t',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                  ),
                  _SummaryStat(
                    label: 'Séries',
                    value: '$totalSets',
                    icon: Icons.list_alt,
                    color: Colors.green,
                  ),
                ],
              ).animate().slideY(begin: 0.2, end: 0, delay: 500.ms).fadeIn(),
              const SizedBox(height: 48),

              // Intensity Slider
              Text(
                'Como foi o treino?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('😎'),
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
                  const Text('🥵'),
                ],
              ),
              Center(
                child: Text(
                  [
                    'Fácil',
                    'Moderado',
                    'Bom',
                    'Intenso',
                    'Insano',
                  ][intensity.value.toInt() - 1],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'Resumo dos Exercícios',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...sessionLogs.values.map((log) {
                // Note: Ideally we would have the Exercise Name passed here,
                // but for now we might only have ID.
                // In a real app we'd pass a rich object or fetch it.
                // For this demo, we'll genericize it or assume we passed names.
                // Refactoring WorkoutPlayerPage to pass names is complex,
                // so we will just show "Exercício" or ID if name unavailable.
                // Wait, I can't easily get the name here without passing it.
                // I'll update ExerciseSessionLog to include name.
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.check)),
                    title: Text(
                      log.exerciseName ?? 'Exercício ${log.exerciseId}',
                    ),
                    subtitle: Text('${log.setLogs.length} séries concluídas'),
                  ),
                );
              }),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compartilhamento em breve!'),
                            ),
                          );
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
                          // Navigate back to home, clearing stack
                          context.go('/home');
                        },
                        child: const Text('Início'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
