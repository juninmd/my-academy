import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/workout.dart';
import '../models/workout_series.dart';
import '../stores/workout_group_store.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutGroupCreatePage extends HookConsumerWidget {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do treino',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        store.workoutGroup.dateStart = selectedDate;
                      }
                    },
                    child: TextFormField(
                      enabled: false,
                      controller: TextEditingController(
                        text: store.workoutGroup.dateStart
                            .toUtc()
                            .toIso8601String(),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Início do treino',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        store.workoutGroup.dateEnd = selectedDate;
                      }
                    },
                    child: TextFormField(
                      enabled: false,
                      controller: TextEditingController(
                        text: store.workoutGroup.dateEnd
                            .toUtc()
                            .toIso8601String(),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fim do treino',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: store.exercises.length,
                itemBuilder: (context, index) {
                  print(store.exercises.length);
                  print(index);
                  var exercise = store.exercises[index];
                  var exist = false;
                  return Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            exercise.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Séries: 3',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Quantidade de repetições',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Carga',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Descanso',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              var workoutSeries = WorkoutSeries(
                                                  workoutId: 1,
                                                  repetitions: 1,
                                                  rest: 1,
                                                  weight: 1,
                                                  id: 1);
                                              var workout = Workout(
                                                  description: '',
                                                  exerciseId: 1,
                                                  methodId: 1,
                                                  workoutSeries: [
                                                    workoutSeries
                                                  ]);

                                              store.workoutGroup.workouts
                                                  ?.add(workout);
                                              // Adicionar série
                                              print('Adicionar Série');
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.green),
                                            ),
                                            child: const Text(
                                              'Adicionar Série',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Remover série
                                              print('Remover Série');
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red),
                                            ),
                                            child: const Text(
                                              'Remover Série',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            child: exist
                                ? const Text(
                                    'Editar Exercício',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Adicionar Exercício',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Cadastrar grupo de treino
                String trainingName = _nameController.text;
                store.workoutGroup.name = trainingName;
                print('CADASTRAR TREINO');
                store.workoutGroups.add(store.workoutGroup);
                // TODO: Save the training group to API

                // Reset form
                _nameController.clear();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: const Text(
                'Cadastrar Grupo de Treino',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
