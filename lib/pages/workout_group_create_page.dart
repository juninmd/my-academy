import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/workout_series.dart';
import '../stores/workout_group_store.dart';
import 'workout_serie_edit_page.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutGroupCreatePage extends HookConsumerWidget {
  final _nameController = TextEditingController();
  final _seriesList = <WorkoutSeries>[];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, []);

    void createWorkoutGroup() {
      String trainingName = _nameController.text;
      store.workoutGroup.name = trainingName;
      store.workoutGroups.add(store.workoutGroup);
      // TODO: Save the training group to API

      // Reset form
      _nameController.clear();
      _seriesList.clear();
    }

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
            TextFormField(
              onChanged: (value) {
                store.filterExercises(value.toLowerCase());
              },
              decoration: const InputDecoration(
                labelText: 'Filtrar exercícios',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: store.filteredExercises.length,
                itemBuilder: (context, index) {
                  var exercise = store.filteredExercises[index];
                  var exist = true;
                  return Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Image.network(
                                    exercise.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                              Text(
                                'Séries: ${_seriesList.length}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Card(
                                child: WorkoutSerieEdit(
                                    exercise: exercise,
                                    seriesList: _seriesList),
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        child: Text(
                          exist ? 'Editar Exercício' : 'Adicionar Exercício',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createWorkoutGroup();
                print('CADASTRAR TREINO');
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
