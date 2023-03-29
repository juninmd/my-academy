import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise.dart';
import 'package:my_academy/repository/exercise_repository.dart';
import 'package:my_academy/widgets/exercise_card.dart';

import '../repository/exercise_group_repository.dart';

class ExerciseListPage extends StatefulWidget {
  final int idGroup;
  final String description;

  const ExerciseListPage(
      {Key? key, required this.idGroup, required this.description})
      : super(key: key);

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
    _exercises = exercises
        .where((element) => element.exerciseGroup == widget.idGroup)
        .toList();
    _title = exerciseGroups
        .firstWhere((element) => element.id == widget.idGroup)
        .name;
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: size.height * 0.3,
                  pinned: true,
                  floating: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(38),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 12.0, right: 12.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 24.0),
                          hintText: 'Procurar Exercício',
                          iconColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.black),
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
                    _title,
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
                            _exercises = exercises
                                .where((element) =>
                                    element.exerciseGroup == widget.idGroup)
                                .toList();
                          });
                        },
                        icon: const Icon(Icons.clear))
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                      background:
                          Stack(fit: StackFit.expand, children: <Widget>[
                    Image.asset(
                      "assets/images/bg2.jpg",
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
                              widget.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100),
                            )),
                      ),
                    ),
                  ])),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: _exercises.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: _exercises.length,
                      itemBuilder: (BuildContext context, int index) {
                        var exercise = _exercises[index];
                        return ExerciseCardPage(exercise: exercise);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5,
                        mainAxisExtent: 200,
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text('Nenhum exercício encontrado'),
                      ),
                    ),
            )));
  }
}
