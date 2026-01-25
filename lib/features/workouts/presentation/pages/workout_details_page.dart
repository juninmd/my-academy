import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_card.dart';

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

          return NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(group.name),
                      background:
                          group.image != null
                              ? CachedNetworkImage(
                                imageUrl: group.image!,
                                fit: BoxFit.cover,
                                color: Colors.black45,
                                colorBlendMode: BlendMode.darken,
                                errorWidget:
                                    (c, e, s) => Container(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
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

                              final user =
                                  ref.read(authNotifierProvider).value;
                              if (user != null) {
                                ref.invalidate(
                                  workoutGroupsProvider(user.id),
                                );
                              }

                              if (context.mounted) context.pop();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
            body:
                group.workouts.isEmpty
                    ? const Center(child: Text('Nenhum exercício neste treino'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                      itemCount: group.workouts.length,
                      itemBuilder: (context, index) {
                        final workout = group.workouts[index];
                        return WorkoutCard(
                          workout: workout,
                          onTap: () {
                            if (workout.exercise != null) {
                              context.push('/exercise-details',
                                  extra: workout.exercise);
                            }
                          },
                          onLongPress: () {
                            // Show Details Dialog
                          },
                        );
                      },
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
