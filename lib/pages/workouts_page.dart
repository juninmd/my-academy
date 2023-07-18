import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_academy/widgets/workout_card.dart';
import '../models/workout.dart';
import '../models/workout_group.dart';
import '../services/my_academy/workout_group_api.dart';
import '../utils.dart';
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
    super.initState();
    List<String> imagePaths = [
      'assets/images/bg1.jpg',
      'assets/images/bg2.jpg',
      'assets/images/bg3.jpg',
      'assets/images/bg4.jpg',
      'assets/images/bg5.jpg',
      'assets/images/bg6.jpg',
    ];

    background = getRandomImagePath(imagePaths);
    loadValues();
  }

  loadValues() async {
    setState(() {
      isLoading = true;
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
            expandedHeight: size.height * 0.25,
            pinned: true,
            floating: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(38),
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 20, left: 12.0, right: 12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 24.0),
                    hintText: 'Procurar Exercício',
                    iconColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filterExercises(value);
                    });
                  },
                ),
              ),
            ),
            title: Text(
              widget.workoutGroup.name,
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            toolbarHeight: 100,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _workouts = _workoutsBase;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
              IconButton(
                onPressed: () async {
                  await ConfirmFinishWorkout(
                      context, getDateNow(), '-1001661357785', () async {
                    Navigator.of(context).pop(true);
                    widget.callback();
                  }, widget.workoutGroup.id);
                },
                color: Colors.deepPurple,
                icon: const Icon(Icons.check),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    background, // random
                    fit: BoxFit.cover,
                    color: const Color(0xaa212121),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 12.0, top: 10.0, right: 12.0),
                        child: Text(
                          'Período de treino de ${DateFormat('dd/MM/yyyy').format(widget.workoutGroup.dateStart)} até ${DateFormat('dd/MM/yyyy').format(widget.workoutGroup.dateEnd)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      crossAxisCount: 1,
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
              channelName: '-1001661357785',
              message: getDateNow(),
              workoutGroupId: widget.workoutGroup.id!,
              callback: () async {
                Navigator.of(context).pop(true);
                widget.callback();
              },
            )
          : null,
    );
  }

  String getDateNow() {
    final date = DateTime.now();
    return "${date.day}/${date.month}/${date.year} - ${widget.workoutGroup.description}";
  }
}
