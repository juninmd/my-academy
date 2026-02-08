import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weekly_progress_card.dart';
import '../widgets/streak_card.dart';
import '../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../workouts/presentation/widgets/workout_history_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
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
                                fontSize: 24,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          user?.name?.split(' ').first ?? 'Atleta',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          StreakCard(completedWorkouts: summary.counter),
                          const SizedBox(height: 12),
                          const WeeklyProgressCard(),
                          const SizedBox(height: 32),

                          // Quick Actions Grid (Replaces old Tools)
                          const QuickActionsGrid(),
                          const SizedBox(height: 32),

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
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'HOJE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Próximo Treino',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    summary.workoutName ?? 'Treino Personalizado',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
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
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        'INICIAR TREINO',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
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
