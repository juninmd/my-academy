import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/exercise.dart';
import '../models/workout_series.dart';
import '../stores/workout_group_create_store.dart';

final workoutGroupCreateStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupCreateStore());

class WorkoutSerieEdit extends HookConsumerWidget {
  final int? workoutId;
  final Exercise exercise;
  final void Function(
      List<WorkoutSeries> value, Exercise exercise, int? workoutId) onTap;

  const WorkoutSerieEdit({
    Key? key,
    this.workoutId,
    required this.exercise,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupCreateStoreProvider);

    List<TextEditingController> repetitionsControllers = [];
    List<TextEditingController> restControllers = [];
    List<TextEditingController> weightControllers = [];

    // Helper function to ensure controllers list matches the seriesList length
    void updateControllersList() {
      for (var i = repetitionsControllers.length; i < store.seriesList.length; i++) {
        repetitionsControllers.add(TextEditingController(text: store.seriesList[i].repetitions.toString()));
        restControllers.add(TextEditingController(text: store.seriesList[i].rest.toString()));
        weightControllers.add(TextEditingController(text: store.seriesList[i].weight.toString()));
      }
    }

    updateControllersList();

    useEffect(() {
      print('useEffect');
      store.loadWorkoutsSeriesByWorkout(workoutId, exercise.id);
      updateControllersList();

      print(repetitionsControllers.length);
      print(store.seriesList.length);
    }, [workoutId, exercise.id]);

    void addSeries(int index) {
      store.seriesList[index].repetitions = int.parse(repetitionsControllers[index].text);
      store.seriesList[index].rest = int.parse(restControllers[index].text);
      store.seriesList[index].weight = int.parse(weightControllers[index].text);
      store.seriesList.add(
        WorkoutSeries(
          workoutId: workoutId,
          repetitions: int.parse(repetitionsControllers[index].text),
          rest: int.parse(restControllers[index].text),
          weight: int.parse(weightControllers[index].text),
          id: null,
        ),
      );
      store.notify();
    }

    void removeSeries(int index) {
      store.seriesList.removeAt(index);
      store.notify();
    }

    void updateSerie(int index) {
      store.seriesList[index].repetitions =
          int.parse(repetitionsControllers[index].text);
      store.seriesList[index].rest = int.parse(restControllers[index].text);
      store.seriesList[index].weight = int.parse(weightControllers[index].text);
      store.notify();
    }

    void saveSeries() {
      print('saveSeries');
      onTap(store.seriesList, exercise, workoutId);
      store.notify();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Séries'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var seriesIndex = 0;
                  seriesIndex < store.seriesList.length;
                  seriesIndex++)
                Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade de repetições',
                      ),
                      controller: repetitionsControllers[seriesIndex],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carga',
                      ),
                      controller: weightControllers[seriesIndex],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Descanso',
                      ),
                      controller: restControllers[seriesIndex],
                    ),
                    const SizedBox(height: 16),
                    if (seriesIndex == 0)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                addSeries(seriesIndex);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
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
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateSerie(
                                  seriesIndex,
                                );
                              },
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
                  saveSeries();
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
