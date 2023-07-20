import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
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

    var nameController = TextEditingController(
      text: store.workoutGroup.name,
    );

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
                  child:TextFormField(
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      var dateNow = DateTime.now();
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dateNow,
                        firstDate: dateNow,
                        lastDate: dateNow.add(new Duration(days: 90)),
                      );
                      if (selectedDate != null) {
                        store.workoutGroup.dateStart = selectedDate.toUtc();
                        store.notify();
                      }
                    },
                    child: TextFormField(
                      enabled: false,
                      // onChanged: (value){
                      //   store.workoutGroup.dateStart = value as DateTime;
                      //   store.notify();
                      // },
                      controller: TextEditingController(
                        text: DateFormat('dd/MM/yyyy').format(store.workoutGroup.dateStart.toUtc())
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
                      var dateNow = DateTime.now();
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dateNow,
                        firstDate: dateNow,
                        lastDate: dateNow.add(new Duration(days: 90)),
                      );
                      if (selectedDate != null) {
                        store.workoutGroup.dateEnd = selectedDate.toUtc();
                        store.notify();
                      }
                    },
                    child: TextFormField(
                      enabled: false,
                      // onChanged: (value){
                      //   store.workoutGroup.dateEnd = value as DateTime;
                      //   store.notify();
                      // },
                      controller: TextEditingController(
                        text: DateFormat('dd/MM/yyyy').format(store.workoutGroup.dateEnd.toUtc())
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fim do treino',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: store.workoutGroup.level,
                    onChanged: (value) {
                      store.workoutGroup.level = value!;
                      store.notify();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nível',
                    ),
                    items: [
                      for (int level = 1; level <= 5; level++)
                        DropdownMenuItem<int>(
                          value: level,
                          child: Text('Nível $level'),
                        ),
                    ],
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
      color: Colors.black,
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
                child: Stack(
                  children: [
                    Image.asset(
                      exercise.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 100, // Defina a altura desejada para a imagem
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                        onTap: (workoutSeries, methodId) {
                          store.addWorkout(
                              null, exercise.id, workoutSeries, methodId);
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
