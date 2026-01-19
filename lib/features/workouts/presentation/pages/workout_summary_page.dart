import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/session_log_entity.dart';

class WorkoutSummaryPage extends StatelessWidget {
  const WorkoutSummaryPage({
    required this.duration,
    required this.sessionLogs,
    super.key,
  });

  final Duration duration;
  final Map<int, ExerciseSessionLog> sessionLogs;

  @override
  Widget build(BuildContext context) {
    int totalSets = 0;
    int totalReps = 0;
    int totalWeight = 0;

    for (final log in sessionLogs.values) {
      for (final set in log.setLogs.values) {
        if (set.isCompleted) {
          totalSets++;
          totalReps += set.actualReps;
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
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
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
                     title: Text(log.exerciseName ?? 'Exercício ${log.exerciseId}'),
                     subtitle: Text('${log.setLogs.length} séries concluídas'),
                   ),
                 );
              }),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home, clearing stack
                    context.go('/home');
                  },
                  child: const Text('Voltar ao Início'),
                ),
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
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
