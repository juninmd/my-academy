import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../workouts/presentation/widgets/plate_calculator_dialog.dart';
import '../../../workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';
import '../widgets/quick_timer_dialog.dart';

// Placeholder for now
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino do dia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hello Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage:
                        user?.photoUrl != null
                            ? CachedNetworkImageProvider(user!.photoUrl!)
                            : null,
                    child:
                        user?.photoUrl == null
                            ? Text(
                              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá,',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        user?.name?.split(' ').first ?? 'Atleta',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Section
            ref
                .watch(workoutSummaryProvider)
                .when(
                  data:
                      (summary) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.local_fire_department,
                                  label: 'Frequência',
                                  value: '${summary.counter} dias',
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Placeholder for minutes if not available
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.timer,
                                  label: 'Último',
                                  value:
                                      summary.lastSessionDate != null
                                          ? DateFormat('dd/MM').format(
                                            DateTime.parse(
                                              summary.lastSessionDate!,
                                            ),
                                          )
                                          : '-',
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _ToolsSection(),
                          const SizedBox(height: 24),

                          // Workout Card
                          if (summary.hasWorkoutToday)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.tertiary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Treino de Hoje',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    summary.workoutName ??
                                        'Treino Personalizado',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (summary.workoutGroupId != null) {
                                          context.go(
                                            '/workouts/${summary.workoutGroupId}',
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      child: const Text('Iniciar Treino'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Descanso Merecido',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Nenhum treino programado para hoje.',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erro: $err')),
                ),
          ],
        ),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ferramentas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ToolCard(
                icon: Icons.calculate_outlined,
                label: 'Anilhas',
                color: Colors.blue,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const PlateCalculatorDialog(targetWeight: 0),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToolCard(
                icon: Icons.fitness_center,
                label: '1RM',
                color: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const OneRepMaxCalculatorDialog(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToolCard(
                icon: Icons.timer_outlined,
                label: 'Descanso',
                color: Colors.orange,
                onTap: () {
                   showDialog(
                     context: context,
                     builder: (context) => const QuickTimerDialog(),
                   );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 12),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
    properties.add(ColorProperty('color', color));
  }
}
