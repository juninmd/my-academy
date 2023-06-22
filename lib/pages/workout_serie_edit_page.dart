import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../dto/workout_series_dto.dart';
import '../models/exercise.dart';
import '../stores/workout_group_store.dart';
import '../widgets/full_screen_image.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutSerieEdit extends HookConsumerWidget {
  final int? workoutId;
  final Exercise exercise;
  final List<WorkoutSeriesDTO> seriesList;
  final void Function(List<WorkoutSeriesDTO> value) onTap;

  const WorkoutSerieEdit({
    Key? key,
    this.workoutId,
    required this.exercise,
    required this.seriesList,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var repetitionsController = useTextEditingController(text: '15');
    var restController = useTextEditingController(text: '60');
    var weightController = useTextEditingController(text: '10');

    final store = ref.watch(workoutGroupStoreProvider);

    void addSeries() {
      print('addSeries');
      seriesList.add(
        WorkoutSeriesDTO(
          workoutId: workoutId,
          repetitionsController:
              TextEditingController(text: repetitionsController.text),
          restController: TextEditingController(text: restController.text),
          weightController: TextEditingController(text: weightController.text),

          repetitions: int.parse(repetitionsController.text),
          rest: int.parse(restController.text),
          weight: int.parse(weightController.text),
        ),
      );
      print('addSeries');
      store.notify();
    }

    void removeSeries(int index) {
      print('removeSeries ${index}');
      seriesList.removeAt(index);
      store.notify();
    }

    void updateSerie(int index) {
      print('updateSerie ${index}');

      seriesList[index].rest =
          int.parse(seriesList[index].restController!.text);
      seriesList[index].repetitions =
          int.parse(seriesList[index].repetitionsController!.text);
      seriesList[index].weight =
          int.parse(seriesList[index].weightController!.text);
      store.notify();
    }

    void saveSeries() {
      print('saveSeries');
      onTap(seriesList);
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
              Column(
                children: [
                  ListTile(
                    title: Text(
                      exercise.name,
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
                    controller: repetitionsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de repetições',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Carga',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                   controller: restController,
                    keyboardType: TextInputType.number,
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
                                MaterialStateProperty.all<Color>(Colors.green),
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade de repetições',
                      ),
                      controller: seriesList[seriesIndex].repetitionsController,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carga',
                      ),
                      controller: seriesList[seriesIndex].weightController,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Descanso',
                      ),
                      controller: seriesList[seriesIndex].restController,
                    ),
                    const SizedBox(height: 16),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
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
                                  MaterialStateProperty.all<Color>(Colors.red),
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
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Salvar Séries',
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
