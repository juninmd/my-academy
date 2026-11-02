import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout_entity.dart';
import '../providers/workout_provider.dart';
import '../../../../core/widgets/app_image.dart';

class WorkoutDetailsPage extends ConsumerWidget {
  const WorkoutDetailsPage({required this.groupId, super.key});
  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(workoutGroupByIdProvider(groupId));

    return Scaffold(
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Treino não encontrado'));
          }

          // Summary Calculations
          final totalExercises = group.workouts.length;
          final totalSets = group.workouts.fold(
            0,
            (sum, w) => sum + w.series.length,
          );
          // Est duration: ~45s per set + rest time per set
          // If rest is 0, assume 60s
          final totalSeconds = group.workouts.fold(0, (sum, w) {
            return sum +
                w.series.fold(
                  0,
                  (sSum, s) => sSum + 45 + (s.rest > 0 ? s.rest : 60),
                );
          });
          final estMinutes = (totalSeconds / 60).round();

          return NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    // White on primary/darkened photo keeps WCAG contrast.
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        group.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      background:
                          group.image != null
                              ? AppImage(
                                source: group.image!,
                                fit: BoxFit.cover,
                                color: Colors.black45,
                                colorBlendMode: BlendMode.darken,
                                fallback: Container(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                              : Container(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    actions: [
                      PopupMenuButton(
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Deletar'),
                              ),
                            ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            context.go('/workouts/create', extra: group);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Deletar Treino'),
                                    content: const Text(
                                      'Tem certeza que deseja deletar este treino?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Deletar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true && context.mounted) {
                              final repo = ref.read(workoutRepositoryProvider);
                              await repo.deleteWorkoutGroup(groupId);

                              final user = ref.read(authNotifierProvider).value;
                              if (user != null) {
                                ref.invalidate(workoutGroupsProvider(user.id));
                              }

                              if (context.mounted) context.pop();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: 'Exercícios',
                          value: '$totalExercises',
                          icon: Icons.list,
                        ),
                        _SummaryItem(
                          label: 'Séries',
                          value: '$totalSets',
                          icon: Icons.fitness_center,
                        ),
                        _SummaryItem(
                          label: 'Tempo Est.',
                          value: '${estMinutes}min',
                          icon: Icons.timer,
                        ),
                      ],
                    ),
                  ),
                ),
                if (group.workouts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('Nenhum exercício neste treino')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final workout = group.workouts[index];
                      return _WorkoutListItem(workout: workout, index: index);
                    }, childCount: group.workouts.length),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/workouts/$groupId/player');
        },
        label: const Text('Iniciar Treino'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('groupId', groupId));
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({required this.workout, required this.index});

  final WorkoutEntity workout;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (workout.exercise != null) {
            context.push('/exercise-details', extra: workout.exercise);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    workout.exercise?.image != null
                        ? AppImage(
                          source: workout.exercise!.image!,
                          fit: BoxFit.cover,
                          fallback: const Icon(Icons.fitness_center),
                        )
                        : const Icon(Icons.fitness_center),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (workout.supersetGroup != null)
                      Text(
                        'Superset ${workout.supersetGroup}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      workout.exercise?.name ?? 'Exercício Indisponível',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _DetailBadge(
                          icon: Icons.repeat,
                          text: '${workout.series.length} séries',
                          color: Colors.blue,
                        ),
                        if (workout.series.isNotEmpty)
                          _DetailBadge(
                            icon: Icons.timer_outlined,
                            text: '${workout.series.first.rest}s',
                            color: Colors.orange,
                          ),
                      ],
                    ),
                    if (workout.series.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${workout.series.first.repetitions} reps @ ${workout.series.first.weight}kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
