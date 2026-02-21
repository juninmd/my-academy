import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

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
              const SizedBox(height: 16),
              // Shareable Card Section
              RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Colors.amber,
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryStat(
                            label: 'Tempo',
                            value: _formatDuration(duration),
                            icon: Icons.timer_outlined,
                            color: Colors.blue,
                          ),
                          Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                          _SummaryStat(
                            label: 'Volume',
                            value: '${(totalWeight / 1000).toStringAsFixed(1)}t',
                            icon: Icons.fitness_center,
                            color: Colors.orange,
                          ),
                          Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                          _SummaryStat(
                            label: 'Séries',
                            value: '$totalSets',
                            icon: Icons.list_alt,
                            color: Colors.green,
                          ),
                        ],
                      ).animate().slideY(begin: 0.2, end: 0, delay: 500.ms).fadeIn(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Equivalente a levantar',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getWeightEquivalence(totalWeight),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 600.ms),

                      if (newRecords.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.military_tech, color: Colors.amber),
                             SizedBox(width: 8),
                             Text('Novos Recordes', style: TextStyle(fontWeight: FontWeight.bold)),
                           ],
                        ),
                        const SizedBox(height: 8),
                        ...newRecords.take(3).map((record) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(record, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        )),
                        if (newRecords.length > 3)
                          Text('+${newRecords.length - 3} outros', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            label: ['Fácil', 'Moderado', 'Bom', 'Intenso', 'Insano'][intensity.value.toInt() - 1],
                            onChanged: (v) => intensity.value = v,
                          ),
                        ),
                        const Text('🥵', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    Text(
                        ['Fácil', 'Moderado', 'Bom', 'Intenso', 'Insano'][intensity.value.toInt() - 1],
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
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
                          final volumeStr = (totalWeight / 1000).toStringAsFixed(1);
                          String text = '🔥 Treino Concluído no MyAcademy!\n\n';
                          text += '⏱️ Duração: $durationStr\n';
                          text += '💪 Volume Total: ${volumeStr}ton\n';
                          text += '🏋️ Equivalente a: ${_getWeightEquivalence(totalWeight)}\n';

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
                           backgroundColor: Theme.of(context).colorScheme.primary,
                           foregroundColor: Colors.white,
                        ),
                        child: const Text('Concluir', style: TextStyle(fontWeight: FontWeight.bold)),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
