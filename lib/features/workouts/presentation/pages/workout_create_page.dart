import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/workout_create_provider.dart';
import '../widgets/workout_series_dialog.dart';

class WorkoutCreatePage extends HookConsumerWidget {
  const WorkoutCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final searchController = useTextEditingController();
    final searchTerm = useState('');

    final exercisesAsync = ref.watch(exercisesProvider);
    final notifier = ref.read(workoutCreateNotifierProvider.notifier);
    final draftGroup = ref.watch(workoutCreateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Treino')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name Input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Treino'),
              onChanged: (val) => notifier.updateName(val),
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Procurar Exercícios',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => searchTerm.value = val,
            ),
            const SizedBox(height: 16),

            // Exercises List
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  final filtered =
                      exercises
                          .where(
                            (e) => e.name.toLowerCase().contains(
                              searchTerm.value.toLowerCase(),
                            ),
                          )
                          .toList();
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exercise = filtered[index];
                      final isAdded = draftGroup.workouts.any(
                        (w) => w.exerciseId == exercise.id,
                      );

                      return Card(
                        color:
                            isAdded
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (exercise.image != null)
                                SizedBox(
                                  height: 60,
                                  child: Image.network(
                                    exercise.image!,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            const Icon(Icons.fitness_center),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                exercise.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isAdded)
                                const Text(
                                  'Adicionado',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
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

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final user = ref.read(authNotifierProvider).value;
                  if (user != null) {
                    await notifier.saveGroup(user.id);
                    if (context.mounted) context.pop();
                  }
                },
                child: const Text('Salvar Treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
