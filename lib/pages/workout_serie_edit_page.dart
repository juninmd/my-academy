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
    var repetitionsController = useTextEditingController(text: '15');
    var restController = useTextEditingController(text: '60');
    var weightController = useTextEditingController(text: '10');

    final store = ref.watch(workoutGroupCreateStoreProvider);

    useEffect(() {
      store.loadWorkoutsSeriesByWorkout(workoutId, exercise.id);
      return null;
    }, const []);

    void addSeries() {
      store.seriesList.add(
        WorkoutSeries(
          workoutId: workoutId,
          repetitions: int.parse(repetitionsController.text),
          rest: int.parse(restController.text),
          weight: int.parse(weightController.text),
          id: null,
        ),
      );
      store.notify();
    }

    void removeSeries(int index) {
      print('removeSeries ${index}');
      store.seriesList.removeAt(index);
      store.notify();
    }

    void updateSerie(int index) {
      print('updateSerie ${index}');

      store.seriesList[index].rest = 0;
      store.seriesList[index].repetitions = 0;
      store.seriesList[index].weight = 0;
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
                      controller: TextEditingController(
                          text: repetitionsController.text),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carga',
                      ),
                      controller:
                          TextEditingController(text: weightController.text),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Descanso',
                      ),
                      controller:
                          TextEditingController(text: restController.text),
                    ),
                    const SizedBox(height: 16),
                    if (seriesIndex == 0)
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
