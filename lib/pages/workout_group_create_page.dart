import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../constants.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_group.dart';
import '../services/my_academy/exercises_api.dart';

class WorkoutGroupCreatePage extends StatefulWidget {
  WorkoutGroupCreatePage();

  @override
  _WorkoutGroupCreatePageState createState() => _WorkoutGroupCreatePageState();
}

class _WorkoutGroupCreatePageState extends State<WorkoutGroupCreatePage> {
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  List<Workout> _workouts = [Workout(exerciseId: 1, description: '')];

  WorkoutGroup _workoutGroup = WorkoutGroup(
      name: '',
      description: '',
      image: '',
      dateStart: DateTime.now(),
      dateEnd: DateTime.now(),
      level: 1,
      userId: idUser);

  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    var exercises = await getExercises();
    setState(() {
      _exercises = exercises;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                          setState(() {
                            _startDate = selectedDate;
                          });
                        }
                      },
                      child: TextFormField(
                        enabled: false,
                        controller: TextEditingController(
                          text: _startDate != null
                              ? _startDate!.toString()
                              : 'Início do treino',
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
                          setState(() {
                            _endDate = selectedDate;
                          });
                        }
                      },
                      child: TextFormField(
                        enabled: false,
                        controller: TextEditingController(
                          text: _endDate != null
                              ? _endDate!.toString()
                              : 'Fim do treino',
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
              Expanded(
                child: ListView.builder(
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    var exercise = _exercises[index];
                    var exist = _workouts.firstWhereOrNull(
                            (x) => x.exerciseId == exercise.id) !=
                        null;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                                const Text(
                                  'Séries: 3',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing:Column (
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Quantidade de repetições',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Carga',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Descanso',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Adicionar série
                                                  print('Adicionar Série');
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.green),
                                                ),
                                                child: const Text(
                                                  'Adicionar Série',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Remover série
                                                  print('Remover Série');
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.red),
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
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                                ),
                                child: exist
                                    ? const Text(
                                  'Editar Exercício',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Adicionar Exercício',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        )
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Cadastrar grupo de treino
                  String trainingName = _nameController.text;

                  WorkoutGroup newTrain = WorkoutGroup(
                    name: trainingName,
                    description: '',
                    userId: idUser,
                    dateStart: _startDate ?? DateTime.now(),
                    dateEnd: _endDate ?? DateTime.now(),
                    image: '',
                    level: 1,
                  );

                  print('CADASTRAR TREINO');

                  setState(() {
                    // _workouts.add()
                    // _trainingGroups.add(newTrainingGroup);
                  });

                  // TODO: Save the training group to API

                  // Reset form
                  _nameController.clear();
                  _startDate = null;
                  _endDate = null;
                  // _exercises.clear();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
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
