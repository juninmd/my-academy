import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShareableWorkoutCard extends StatelessWidget {
  const ShareableWorkoutCard({
    required this.duration,
    required this.totalWeight,
    required this.totalSets,
    required this.newRecords,
    super.key,
  });

  final Duration duration;
  final double totalWeight;
  final int totalSets;
  final List<String> newRecords;

  String _getWeightEquivalence(double weightKg) {
    if (weightKg < 100) return 'um Lobo Grande 🐺';
    if (weightKg < 500) return 'um Urso Pardo 🐻';
    if (weightKg < 1000) return 'um Piano de Cauda 🎹';
    if (weightKg < 2000) return 'um Carro Compacto 🚗';
    if (weightKg < 5000) return 'um Elefante 🐘';
    if (weightKg < 10000) return 'um T-Rex 🦖';
    return 'um Ônibus Espacial 🚀';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.35),
              Theme.of(context).cardTheme.color ??
                  Theme.of(context).colorScheme.surface,
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
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Ótimo trabalho hoje.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                _SummaryStat(
                  label: 'Volume',
                  value: '${(totalWeight / 1000).toStringAsFixed(1)}t',
                  icon: Icons.fitness_center,
                  color: Colors.orange,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
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
                  Text(
                    'Novos Recordes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...newRecords
                  .take(3)
                  .map(
                    (record) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        record,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              if (newRecords.length > 3)
                Text(
                  '+${newRecords.length - 3} outros',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ],
        ),
      ),
    );
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
