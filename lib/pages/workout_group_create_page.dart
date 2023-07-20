import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/exercise.dart';
import '../stores/workout_group_create_store.dart';
import 'workout_serie_edit_page.dart';
import 'package:collection/collection.dart';

class WorkoutGroupCreatePage extends HookConsumerWidget {
  final int idUser;

  WorkoutGroupCreatePage(this.idUser, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupCreateStoreProvider);

    useEffect(() {
      store.loadValues(idUser);
      return null;
    }, []);

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
                    controller: TextEditingController(
                      text: store.workoutGroup.name,
                    ),
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
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: store.workoutGroup.level.toString(),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nível',
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
                    return Column(
                      children: [
                        ExerciseCard(exercise: exercise, onTap: () {}),
                      ],
                    );
                  }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                store.createWorkoutGroup(idUser);
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

class ExerciseCard extends HookConsumerWidget {
  const ExerciseCard({Key? key, required this.exercise, required this.onTap})
      : super(key: key);
  final Exercise exercise;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupCreateStoreProvider);

    var series = store.workouts
            .firstWhereOrNull((element) => element.exerciseId == exercise.id)
            ?.workoutSeries ??
        [];

    return Card(
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
                  print('series antes de clicar');
                  var series = store.workouts
                      .firstWhereOrNull((element) => element.exerciseId == exercise.id)
                      ?.workoutSeries ??
                      [];
                  print(series);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) => Card(
                      child: WorkoutSerieEdit(
                        exercise: exercise,
                        onTap: (workoutSeries, methodId) {
                          store.addWorkout(
                              null, exercise.id, workoutSeries,methodId);
                          store.notify();
                        },
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
                child: Text(
                  '${series.length == 0 ? 'Adicionar Exercício' : 'Editar Exercício'}',
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
                        '${series.length} Série(s)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
