import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../workouts/presentation/widgets/plate_calculator_dialog.dart';
import '../../../workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';
import '../widgets/quick_timer_dialog.dart';
import '../widgets/weekly_progress_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/body_weight_dialog.dart';
import '../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../workouts/presentation/widgets/workout_history_card.dart';

// Placeholder for now
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;
    final groupsAsync = user != null
        ? ref.watch(workoutGroupsProvider(user.id))
        : const AsyncValue<List<WorkoutGroupEntity>>.data([]);

    final logsAsync = ref.watch(allExerciseLogsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

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
        icon: const Icon(Icons.fitness_center),
        label: const Text('Treino Rápido'),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreakCard(completedWorkouts: summary.counter),
                          const SizedBox(height: 12),
                          const WeeklyProgressCard(),
                          const SizedBox(height: 24),

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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Show Last Workout if available
                                logsAsync.when(
                                  data: (logs) {
                                    if (logs.isEmpty) return const _GenericRestCard();

                                    // Find latest date
                                    final latestLog = logs.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
                                    final latestDate = latestLog.date;

                                    // Filter logs for that date
                                    final sessionLogs = logs.where((e) =>
                                      e.date.year == latestDate.year &&
                                      e.date.month == latestDate.month &&
                                      e.date.day == latestDate.day
                                    ).toList();

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Último Treino',
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 12),
                                        exercisesAsync.when(
                                          data: (exercises) {
                                            final map = {for (var e in exercises) e.id: e.name};
                                            return WorkoutHistoryCard(
                                              date: latestDate,
                                              logs: sessionLogs,
                                              exerciseNameMap: map
                                            );
                                          },
                                          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                                          error: (e, s) => const _GenericRestCard(),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                                  error: (e, s) => const _GenericRestCard(),
                                ),

                                const SizedBox(height: 24),
                                Text(
                                  'Seus Planos',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 140,
                                  child: groupsAsync.when(
                                    data: (groups) {
                                      if (groups.isEmpty) {
                                        return Center(
                                          child: OutlinedButton.icon(
                                            onPressed: () => context.push('/workouts/create'),
                                            icon: const Icon(Icons.add),
                                            label: const Text('Criar Novo Plano'),
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: groups.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == groups.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  child: InkWell(
                                                    onTap: () => context.push('/workouts/create'),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.primary),
                                                        const SizedBox(height: 8),
                                                        const Text('Criar'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          final group = groups[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: AspectRatio(
                                              aspectRatio: 1.2,
                                              child: Card(
                                                elevation: 2,
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                child: InkWell(
                                                  onTap: () => context.go('/workouts/${group.id}'),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(8),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context).colorScheme.primaryContainer,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons.fitness_center,
                                                            size: 20,
                                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          group.name,
                                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '${group.workouts.length} treinos',
                                                          style: Theme.of(context).textTheme.bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (e, s) => Center(child: Text('Erro: $e')),
                                  ),
                                ),
                              ],
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

class _GenericRestCard extends StatelessWidget {
  const _GenericRestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
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
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 90,
                child: _ToolCard(
                  icon: Icons.add_circle_outline,
                  label: 'Criar',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    context.push('/workouts/create');
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: _ToolCard(
                  icon: Icons.history,
                  label: 'Histórico',
                  color: Colors.deepPurple,
                  onTap: () {
                    context.push('/history');
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: _ToolCard(
                  icon: Icons.menu_book_outlined,
                  label: 'Exercícios',
                  color: Colors.indigo,
                  onTap: () {
                    context.go('/home/exercises');
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: _ToolCard(
                  icon: Icons.bar_chart,
                  label: 'Análise',
                  color: Colors.teal,
                  onTap: () {
                     context.push('/analytics');
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
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
              SizedBox(
                width: 90,
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
              SizedBox(
                width: 90,
                child: _ToolCard(
                  icon: Icons.timer_outlined,
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
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
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
          ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
             // Removed border as elevation provides separation
             // border: Border.all(color: color.withValues(alpha: 0.15)),
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
