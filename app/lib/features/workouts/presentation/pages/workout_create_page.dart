import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/utils/muscle_group_mapper.dart';
import '../providers/favorites_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_create_provider.dart';
import '../widgets/workout_series_dialog.dart';
import '../widgets/workout_edit_series_dialog.dart';

class WorkoutCreatePage extends HookConsumerWidget {
  const WorkoutCreatePage({super.key, this.initialGroup});
  final WorkoutGroupEntity? initialGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(workoutCreateNotifierProvider.notifier);
    final draftGroup = ref.watch(workoutCreateNotifierProvider);

    useEffect(() {
      if (initialGroup != null) {
        Future.microtask(() => notifier.loadGroup(initialGroup!));
      }
      return null;
    }, [initialGroup]);

    final nameController = useTextEditingController(text: draftGroup.name);

    useEffect(() {
      if (nameController.text != draftGroup.name) {
        nameController.text = draftGroup.name;
      }
      return null;
    }, [draftGroup.name]);

    void showExercisePicker() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => const _ExercisePickerSheet(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(initialGroup == null ? 'Novo Treino' : 'Editar Treino'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Treino',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => notifier.updateName(val),
            ),
          ),
          Expanded(
            child:
                draftGroup.workouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum exercício adicionado',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: draftGroup.workouts.length,
                      onReorder: (oldIndex, newIndex) {
                        notifier.reorderWorkouts(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final workout = draftGroup.workouts[index];
                        // Use a composite key that includes the index to force rebuild on reorder?
                        // No, keys must be stable for the ITEM, not the slot.
                        // Using ObjectKey(workout) is best if objects are distinct.
                        // If adding same exercise twice, they might be equal.
                        // However, we rely on the list order.
                        // Let's use ObjectKey for now.
                        return Card(
                          key: ObjectKey(workout),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => WorkoutEditSeriesDialog(
                                      workout: workout,
                                      onSave: (updatedWorkout) {
                                        if (updatedWorkout.series.isEmpty) {
                                          notifier.removeWorkout(index);
                                        } else {
                                          notifier.updateWorkout(
                                            index,
                                            updatedWorkout,
                                          );
                                        }
                                      },
                                    ),
                              );
                            },
                            contentPadding: const EdgeInsets.all(8),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  workout.exercise?.image != null
                                      ? CachedNetworkImage(
                                        imageUrl: workout.exercise!.image!,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (context, url, error) => const Icon(
                                              Icons.fitness_center,
                                            ),
                                      )
                                      : const Icon(Icons.fitness_center),
                            ),
                            title: Text(
                              workout.exercise?.name ??
                                  'Exercício Indisponível',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${workout.series.length} séries • ${workout.series.map((s) => '${s.repetitions}x${s.weight}').join(', ')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => notifier.removeWorkout(index),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.drag_handle, color: Theme.of(context).disabledColor),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final user = ref.read(authNotifierProvider).value;
                  if (user != null) {
                    if (draftGroup.name.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Digite um nome para o treino'),
                        ),
                      );
                      return;
                    }
                    if (draftGroup.workouts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Adicione pelo menos um exercício'),
                        ),
                      );
                      return;
                    }
                    await notifier.saveGroup(user.id);
                    if (context.mounted) context.pop();
                  }
                },
                child: const Text('Salvar Treino'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showExercisePicker,
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

enum FilterType { all, recent }

class _ExercisePickerSheet extends HookConsumerWidget {
  const _ExercisePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchTerm = useState('');
    final filterType = useState(FilterType.all);
    final selectedMuscleGroup = useState<String?>(null);
    final showFavoritesOnly = useState(false);

    final exercisesAsync = ref.watch(exercisesProvider);
    final logsAsync = ref.watch(allExerciseLogsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final favorites = favoritesAsync.value ?? {};

    final notifier = ref.read(workoutCreateNotifierProvider.notifier);
    final draftGroup = ref.watch(workoutCreateNotifierProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar Exercício',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) => searchTerm.value = val,
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected:
                        filterType.value == FilterType.all &&
                        !showFavoritesOnly.value &&
                        selectedMuscleGroup.value == null,
                    onSelected: (selected) {
                      if (selected) {
                        filterType.value = FilterType.all;
                        showFavoritesOnly.value = false;
                        selectedMuscleGroup.value = null;
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Recentes'),
                    selected: filterType.value == FilterType.recent,
                    onSelected: (selected) {
                      filterType.value =
                          selected ? FilterType.recent : FilterType.all;
                      if (selected) {
                        showFavoritesOnly.value = false;
                        selectedMuscleGroup.value = null;
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Favoritos'),
                    selected: showFavoritesOnly.value,
                    avatar: Icon(
                      showFavoritesOnly.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: showFavoritesOnly.value ? Colors.red : null,
                    ),
                    onSelected: (selected) {
                      showFavoritesOnly.value = selected;
                      if (selected) {
                        filterType.value = FilterType.all;
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).dividerColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  ...[
                    'Peito',
                    'Costas',
                    'Pernas',
                    'Ombros',
                    'Bíceps',
                    'Tríceps',
                    'Core',
                    'Outros',
                  ].map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(group),
                        selected: selectedMuscleGroup.value == group,
                        onSelected: (selected) {
                          selectedMuscleGroup.value = selected ? group : null;
                          if (selected) {
                            filterType.value = FilterType.all;
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  var filtered =
                      exercises
                          .where(
                            (e) => e.name.toLowerCase().contains(
                              searchTerm.value.toLowerCase(),
                            ),
                          )
                          .toList();

                  final recentIds =
                      logsAsync.value?.map((l) => l.exerciseId).toSet() ?? {};

                  if (filterType.value == FilterType.recent) {
                    filtered =
                        filtered
                            .where((e) => recentIds.contains(e.id))
                            .toList();
                  }

                  if (showFavoritesOnly.value) {
                    filtered =
                        filtered
                            .where((e) => favorites.contains(e.id))
                            .toList();
                  }

                  if (selectedMuscleGroup.value != null) {
                    filtered =
                        filtered
                            .where(
                              (e) =>
                                  MuscleGroupMapper.getMuscleGroup(e.name) ==
                                  selectedMuscleGroup.value,
                            )
                            .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Nenhum exercício encontrado'),
                    );
                  }

                  return GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      final isAdded = draftGroup.workouts.any(
                        (w) => w.exerciseId == exercise.id,
                      );

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        color:
                            isAdded
                                ? Theme.of(context).colorScheme.primaryContainer
                                    .withValues(alpha: 0.3)
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              isAdded
                                  ? BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                  : BorderSide.none,
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => WorkoutSeriesDialog(
                                    exerciseName: exercise.name,
                                    onSave: (reps, weight, rest) {
                                      notifier.addWorkout(
                                        exercise,
                                        reps,
                                        weight,
                                        rest,
                                      );
                                    },
                                  ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child:
                                    exercise.image != null
                                        ? CachedNetworkImage(
                                          imageUrl: exercise.image!,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (context, url, error) =>
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.fitness_center,
                                                    ),
                                                  ),
                                        )
                                        : Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.fitness_center,
                                          ),
                                        ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        exercise.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (isAdded)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Adicionado',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
        );
      },
    );
  }
}
