import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/exercise.dart';
import '../models/workout_series.dart';
import '../stores/workout_group_create_store.dart';

class WorkoutSerieEdit extends HookConsumerWidget {
  final int? workoutId;
  final Exercise exercise;
  final void Function(List<WorkoutSeries> value, int? methodId) onTap;

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
      for (var i = repetitionsControllers.length;
          i < store.seriesList.length;
          i++) {
        repetitionsControllers.add(TextEditingController(
            text: store.seriesList[i].repetitions.toString()));
        restControllers.add(
            TextEditingController(text: store.seriesList[i].rest.toString()));
        weightControllers.add(
            TextEditingController(text: store.seriesList[i].weight.toString()));
      }
    }

    updateControllersList();

    useEffect(() {
      store
        ..loadWorkoutsSeriesByWorkout(workoutId, exercise.id)
        ..loadMethods();
      return null;
      // updateControllersList();
    }, [workoutId, exercise.id]);

    useEffect(() {
      updateControllersList();
      return null;
    }, [store.workouts]);

    void addSeries(int index) {
      store.seriesList[index].repetitions =
          int.parse(repetitionsControllers[index].text);
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
      onTap(store.seriesList, store.methodId);
      store.notify();
    }

    void updateMethod(String? methodId) {
      store.methodId = methodId != null ? int.parse(methodId) : null;
      store.notify();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Método', // Legenda para o Dropdown
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButtonFormField<String?>(
                    value: store.methodId
                        ?.toString(), // Valor selecionado (null ou um método)
                    onChanged: (methodId) {
                      updateMethod(methodId);
                    },
                    items: [
                      // Adicionar a opção "Nenhum" com valor nulo no início
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Nenhum'),
                      ),
                      // Mapear os métodos disponíveis para itens do dropdown
                      for (var method in store.methods)
                        DropdownMenuItem<String?>(
                          value: method.id.toString(),
                          child: Text(method.name),
                        ),
                    ],
                  ),
                ],
              ),
              for (var seriesIndex = 0;
                  seriesIndex < store.seriesList.length;
                  seriesIndex++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone e campo "Quantidade de repetições"
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade de repetições',
                                icon: Icon(Icons.numbers),
                                hintText: 'Exemplo: 15',
                              ),
                              controller: repetitionsControllers[seriesIndex],
                              onTapOutside: (_) {
                                updateSerie(seriesIndex);
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Ícone e campo "Carga"
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Carga',
                                icon: Icon(Icons.monitor_weight),
                                hintText: 'Exemplo: 30',
                              ),
                              controller: weightControllers[seriesIndex],
                              onTapOutside: (_) {
                                updateSerie(seriesIndex);
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Ícone e campo "Descanso"
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Descanso',
                                icon: Icon(Icons.timer),
                                hintText: 'Exemplo: 60',
                              ),
                              controller: restControllers[seriesIndex],
                              onTapOutside: (_) {
                                updateSerie(seriesIndex);
                              }),
                        ),
                      ],
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
                                  Colors.green,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Adicionar Série',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
                              onPressed: () => removeSeries(seriesIndex),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Remover Série',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              Row(
                children: [
                  if (workoutId != null)
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                          onPressed: () {
                            saveSeries();
                            Navigator.pop(context); // Close the bottom sheet
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Apagar Exercício',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )),
                    ),
                  if (workoutId != null) const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        onPressed: () {
                          saveSeries();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Aplicar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
