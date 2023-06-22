import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants.dart';
import '../dto/workout_series_dto.dart';
import '../models/exercise.dart';
import '../services/my_academy/workout_group_api.dart';
import '../stores/workout_group_store.dart';
import '../utils.dart';
import 'workout_serie_edit_page.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutGroupCreatePage extends HookConsumerWidget {
  final _nameController = TextEditingController();
  final _seriesList = <WorkoutSeriesDTO>[];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, []);

    void createWorkoutGroup() async {
      List<String> imagePaths = [
        'assets/images/bg1.jpg',
        'assets/images/bg2.jpg',
        'assets/images/bg3.jpg',
        'assets/images/bg4.jpg',
        'assets/images/bg5.jpg',
        'assets/images/bg6.jpg',
      ];

      final background = getRandomImagePath(imagePaths);

      String trainingName = _nameController.text;
      store.workoutGroup.name = trainingName;
      store.workoutGroup.image = background;
      store.workoutGroup.userId = idUser;
      store.workoutGroup.level = 1;

      await postWorkoutGroup(store.workoutGroup);

      // Reset form
      _nameController.clear();
      _seriesList.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Treino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do treino',
                    ),
                  ),
                ),
              ],
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
                    final exercise = store.filteredExercises[index];
                    // store.workoutGroups
                    var exist = true;
                    return Column(
                      children: [
                        ExerciseCard(exercise: exercise, onTap: () {}),
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ListTile(
                          title: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Card(
                                  child: WorkoutSerieEdit(
                                    exercise: exercise,
                                    seriesList: _seriesList,
                                    onTap: (value) {
                                      print(value);
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            child: Text(
                              exist
                                  ? 'Editar Exercício'
                                  : 'Adicionar Exercício',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_seriesList.length} Série(s)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
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

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final void Function()? onTap;

  const ExerciseCard({Key? key, required this.exercise, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Stack(children: [
                    Image.asset(
                      exercise.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
}
