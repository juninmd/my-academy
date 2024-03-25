import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/exercise.dart';
import '../stores/workout_group_create_store.dart';
import '../widgets/snackbar.dart';
import 'workout_serie_edit_page.dart';
import 'package:collection/collection.dart';

class WorkoutGroupCreatePage extends HookConsumerWidget {
  final String idUser;
  final int? workoutGroupId;

  WorkoutGroupCreatePage(this.idUser, this.workoutGroupId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupCreateStoreProvider);

    useEffect(() {
      if (workoutGroupId != null) {
        store.loadWorkoutGroup(workoutGroupId!);
      } else {
        store.reset();
      }
      store.loadValues(idUser);
      return null;
    }, [idUser, workoutGroupId]);

    var nameController = TextEditingController(
      text: store.workoutGroup.name,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(workoutGroupId == null ? 'Novo Treino' : 'Editar Treino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      errorText: store.workoutGroup.name.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                      labelText: "Nome do treino",
                    ),
                    onTapOutside: (e) {
                      store.workoutGroup.name = nameController.text;
                      store.notify();
                    },
                    controller: nameController,
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
                flex: 1,
                child: GridView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  itemCount: store.filteredExercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    final exercise = store.filteredExercises[index];
                    return ExerciseCard(
                        exercise: exercise,
                        workoutGroupId: workoutGroupId,
                        onTap: () {});
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    mainAxisExtent: 220,
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  if (store.workoutGroup.name.isEmpty ||
                      store.workouts.isEmpty) {
                    snackBar(
                        context, 'Preencha nome e adicione os exercícios!');
                    return;
                  }
                  if (workoutGroupId == null) {
                    await store.createWorkoutGroup(idUser);
                  } else {
                    await store.updateWorkoutGroup(idUser);
                  }
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 18),
                    SizedBox(width: 8),
                    Text(
                      workoutGroupId == null ? 'Novo Treino' : 'Editar Treino',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class ExerciseCard extends HookConsumerWidget {
  const ExerciseCard(
      {Key? key,
      required this.exercise,
      required this.workoutGroupId,
      required this.onTap})
      : super(key: key);
  final Exercise exercise;
  final int? workoutGroupId;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupCreateStoreProvider);

    var workout = store.workouts
        .firstWhereOrNull((element) => element.exerciseId == exercise.id);
    var series = workout?.workoutSeries ?? [];

    var method = store.methods
        .firstWhereOrNull((element) => element.id == workout?.methodId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, // Distribui os elementos igualmente ao longo do eixo principal
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  exercise.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 80, // Defina a altura desejada para a imagem
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.center, // Centraliza o texto
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              ListTile(
                title: ElevatedButton.icon(
                  icon: Icon(series.isEmpty
                      ? Icons.add
                      : Icons.edit), // Adiciona ícones aos botões
                  label: Text(
                    workout?.id == null
                        ? 'Adicionar Exercício'
                        : 'Editar Exercício',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Card(
                        child: WorkoutSerieEdit(
                          workoutId: workout?.id,
                          exercise: exercise,
                          onTap: (workoutSeries, methodId) {
                            store.addWorkout(workout?.id, exercise.id,
                                workoutSeries, methodId);
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
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      if (method?.name != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centraliza os elementos no eixo principal
                          children: [
                            const Icon(
                              Icons.info,
                              size: 11,
                            ),
                            Text(
                              method?.name ?? 'Sem método',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centraliza os elementos no eixo principal
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${series.length} Série(s)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
