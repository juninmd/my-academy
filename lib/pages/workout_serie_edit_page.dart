import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_series.dart';
import '../stores/workout_group_store.dart';
import '../widgets/full_screen_image.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutSerieEdit extends HookConsumerWidget {
  const WorkoutSerieEdit({
    Key? key,
    required this.exercise,
    required this.seriesList,
  }) : super(key: key);

  final Exercise exercise;
  final List<WorkoutSeries> seriesList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    void addSeries() {
      seriesList.add(
        WorkoutSeries(
          workoutId: 1,
          repetitions: 1,
          rest: 1,
          weight: 1,
          id: seriesList.length + 1,
        ),
      );
      store.notify();
    }

    void removeSeries(int index) {
      seriesList.removeAt(index);
      store.notify();
    }

    void addWorkout() {
      print('a');
      // var selectedExercise =
      //     store.exercises[0]; // Modify this to select the desired exercise
      // var workout = Workout(
      //   description: '',
      //   exerciseId: selectedExercise.id,
      //   methodId: 1,
      //   workoutSeries: seriesList,
      // );
      // store.workoutGroup.workouts?.add(workout);
      store.notify();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Training'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      ListTile(
                        leading: Image.network(
                          exercise.image,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          'Nome da série',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(
                                  imageUrl: exercise.image,
                                ),
                              ),
                            );
                          },
                          child: const Text('Visualizar'),
                        ),
                      ),
                      TextFormField(
                        initialValue: '12',
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de repetições',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: '5',
                        decoration: const InputDecoration(
                          labelText: 'Carga',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: '60',
                        decoration: const InputDecoration(
                          labelText: 'Descanso',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: addSeries,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.green),
                              ),
                              child: const Text(
                                'Adicionar Série',
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
                  for (var seriesIndex = 0;
                      seriesIndex < seriesList.length;
                      seriesIndex++)
                    Column(
                      children: [
                        TextFormField(
                          initialValue:
                              seriesList[seriesIndex].repetitions.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de repetições',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: seriesList[seriesIndex].weight.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Carga',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: seriesList[seriesIndex].rest.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Descanso',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: addSeries,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                child: const Text(
                                  'Atualizar Série',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => removeSeries(seriesIndex),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
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
                  ElevatedButton(
                    onPressed: () {
                      addWorkout();
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: const Text(
                      'Adicionar Exercício',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )),
        ));
  }
}
