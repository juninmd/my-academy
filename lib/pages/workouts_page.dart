import 'package:flutter/material.dart';
import 'package:my_academy/pages/workout_group_create_page.dart';
import 'package:my_academy/widgets/workout_card.dart';
import '../constants.dart';
import '../models/workout.dart';
import '../models/workout_group.dart';
import '../services/my_academy/workout_group_api.dart';
import '../widgets/confirm_delete_workout.dart';
import '../widgets/confirm_finish_workout.dart';
import '../widgets/finish_workout_button.dart';

class WorkoutsPage extends StatefulWidget {
  final WorkoutGroup workoutGroup;
  final Function callback;

  const WorkoutsPage(
      {Key? key, required this.workoutGroup, required this.callback})
      : super(key: key);

  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  List<Workout> _workouts = [];
  List<Workout> _workoutsBase = [];
  bool isLoading = false;
  late String background;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    loadValues();
    super.initState();
  }

  loadValues() async {
    setState(() {
      isLoading = true;
      _workouts = [];
      _workoutsBase = [];
    });

    _searchController = TextEditingController();
    var workouts = await getExercises();

    setState(() {
      _workouts = workouts;
      _workoutsBase = workouts;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateWorkoutStatus(Workout workout) {
    setState(() {
      // Find the index of the exercise in the list
      final index = _workouts.indexWhere((e) => e.id == workout.id);
      if (index != -1) {
        // Update the exercise in the list
        _workouts[index] = workout;
      }
    });
  }

  Future<List<Workout>> getExercises() async {
    var workoutGroup =
        await getWorkoutGroupExercisesById(widget.workoutGroup.id!);
    return workoutGroup.workouts!;
  }

  Future<void> filterExercises(String exerciseName) async {
    if (exerciseName.isEmpty) {
      _workouts = _workoutsBase;
    } else {
      _workouts = _workoutsBase
          .where((e) => e.exercise!.name
              .toLowerCase()
              .contains(exerciseName.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            expandedHeight: size.height * 0.15,
            pinned: true,
            floating: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(38),
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 20, left: 12.0, right: 12.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24.0),
                    hintText: 'Procurar Exercício',
                    helperStyle: TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filterExercises(value);
                    });
                  },
                ),
              ),
            ),
            title: Text(widget.workoutGroup.name),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            toolbarHeight: 100,
            actions: [
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.clear),
                      title: Text('Limpar Procura'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar Treino'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Deletar Treino'),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: ListTile(
                      leading: Icon(Icons.check, color: Colors.white),
                      title: Text('Finalizar Treino'),
                    ),
                  ),
                ],
                onSelected: (int value) async {
                  switch (value) {
                    case 1:
                      setState(() {
                        _searchController.clear();
                        _workouts = _workoutsBase;
                      });
                      break;
                    case 2:
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              WorkoutGroupCreatePage(
                                  FireBaseUser!.uid, widget.workoutGroup.id) ,
                        ),
                      ).then((_) {
                        loadValues();
                      });
                      // Adicione aqui a lógica para editar exercícios
                      break;
                    case 3:
                      ConfirmDeleteWorkout(context, widget.workoutGroup.id,
                          () async {
                        Navigator.of(context).pop(true);
                        widget.callback();
                      });
                      break;
                    case 4:
                      ConfirmFinishWorkout(context, widget.workoutGroup, () async {
                        Navigator.of(context).pop(true);
                        widget.callback();
                      });
                      break;
                  }
                },
              )
            ],
          ),
        ],
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _workouts.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: _workouts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final workout = _workouts[index];
                      return WorkoutCard(
                        onWorkoutStatusChanged: _updateWorkoutStatus,
                        workout: workout,
                      );
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5,
                      mainAxisExtent: null,
                    ),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('Nenhum exercício encontrado'),
                    ),
                  ),
      ),
      floatingActionButton: _workouts.length > 0 &&
              _workouts.where((element) => element.finish).length ==
                  _workouts.length &&
              _searchController.text.isEmpty
          ? FinishWorkoutButton(
              workoutGroup: widget.workoutGroup,
              callback: () async {
                Navigator.pop(context);
                widget.callback();
              },
            )
          : null,
    );
  }
}
