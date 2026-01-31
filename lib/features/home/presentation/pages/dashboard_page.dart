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
import '../widgets/weekly_calendar_strip.dart';
import '../widgets/body_weight_dialog.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/workouts/create'),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Treinar Agora'),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá,',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          user?.name?.split(' ').first ?? 'Atleta',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const WeeklyCalendarStrip(),
                          const SizedBox(height: 24),

                          if (summary.lastSessionDate != null) ...[
                            _RecentActivityCard(
                              lastDate: DateTime.parse(summary.lastSessionDate!),
                              streak: summary.counter,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Tools Section
                          const _ToolsSection(),
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
                                    ).colorScheme.primary.withValues(alpha: 0.4),
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
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.nights_stay_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Descanso Merecido',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Recupere-se para o próximo treino!',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (summary.lastSessionDate != null) ...[
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Último treino: ${DateFormat('dd/MM').format(DateTime.parse(summary.lastSessionDate!))}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      context.go('/workouts/create');
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Criar Nova Rotina'),
                                  ),
                                ],
                              ),
                            ),
                            // Space for FAB
                            const SizedBox(height: 80),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = (constraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.add,
                    label: 'Criar',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      context.push('/workouts/create');
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.history,
                    label: 'Histórico',
                    color: Colors.deepPurple,
                    onTap: () {
                      context.push('/history');
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.menu_book,
                    label: 'Exercícios',
                    color: Colors.indigo,
                    onTap: () {
                      context.go('/home/exercises');
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.bar_chart,
                    label: 'Análise',
                    color: Colors.teal,
                    onTap: () {
                       context.push('/analytics');
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
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
                SizedBox(
                  width: itemWidth,
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
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.timer,
                    label: 'Timer',
                    color: Colors.orange,
                    onTap: () {
                       showDialog(
                         context: context,
                         builder: (context) => const QuickTimerDialog(),
                       );
                    },
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _ToolCard(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso',
                    color: Colors.purple,
                    onTap: () {
                       showDialog(
                         context: context,
                         builder: (context) => const BodyWeightDialog(),
                       );
                    },
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.lastDate, required this.streak});

  final DateTime lastDate;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.orange.withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.local_fire_department, color: Colors.orange),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Atividade Recente',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
                 Text(
                   'Último treino em ${DateFormat('dd/MM').format(lastDate)}',
                   style: Theme.of(context).textTheme.bodySmall,
                 ),
               ],
             ),
           ),
           Column(
             children: [
               Text(
                 '$streak',
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
               ),
               const Text('dias', style: TextStyle(fontSize: 10)),
             ],
           ),
        ],
      ),
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
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
