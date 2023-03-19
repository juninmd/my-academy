import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise.dart';
import 'package:my_academy/repository/exercise_repository.dart';
import 'package:my_academy/widgets/exercise_card.dart';
import 'package:my_academy/widgets/nav_drawer.dart';

import 'repository/exercise_group_repository.dart';

class ExerciseListPage extends StatefulWidget {
  final int idGroup;

  const ExerciseListPage({Key? key, required this.idGroup}) : super(key: key);

  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  List<Exercise> _exercises = [];
  String _title = "";

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _exercises = exercises.where((element) => element.muscleGroup == widget.idGroup).toList();
    _title = exerciseGroups.firstWhere((element) => element.id == widget.idGroup).name;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> getExercises() {
    return exercises;
  }

  void filterExercises(String exerciseName) {
    if (exerciseName.isEmpty) {
      _exercises = getExercises();
    } else {
      _exercises = getExercises()
          .where(
              (e) => e.name.toLowerCase().contains(exerciseName.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _exercises = exercises.where((element) => element.muscleGroup == widget.idGroup).toList();
                });
              },
              icon: Icon(Icons.clear),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Procurar Exercício',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    filterExercises(value);
                  });
                },
              ),
            ),
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  var exercise = _exercises[index];
                  return ExerciseCardPage(exercise: exercise);
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5,
                  mainAxisExtent: 200,
                ),
              ),
            )
          ],
        ));
  }
}
