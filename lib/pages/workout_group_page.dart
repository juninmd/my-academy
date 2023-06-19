import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_academy/pages/workout_group_create_page.dart';

import '../constants.dart';
import '../models/exercise.dart';
import '../models/workout_group.dart';
import '../services/my_academy/exercises_api.dart';
import '../services/my_academy/workout_group_api.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

class WorkoutGroupPage extends StatefulWidget {
  const WorkoutGroupPage({Key? key }) : super(key: key);

  @override
  _WorkoutGroupState createState() => _WorkoutGroupState();
}

class _WorkoutGroupState extends State<WorkoutGroupPage> {
  late Future<List<WorkoutGroup>> _workoutGroupsFuture;
  late Future<List<Exercise>> _exercises;

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    setState(() {
      _workoutGroupsFuture = getWorkoutGroups(idUser);
      _exercises = getExercises();
    });
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
            title: const Text(
              "Meus Treinos",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            toolbarHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    "assets/images/bg1.jpg", // random
                    fit: BoxFit.cover,
                    color: const Color(0xaa212121),
                    colorBlendMode: BlendMode.darken,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: FutureBuilder<List<WorkoutGroup>>(
          future: _workoutGroupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            } else {
              final List<WorkoutGroup> data = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 32.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final workoutGroup = data[index];
                  return FutureBuilder<bool>(
                    future: simulateWidgetLoading(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return WorkoutGroupCardPlaceholder();
                      } else {
                        return WorkoutGroupCard(
                          alreadyWorkout: false,
                          workoutGroup: workoutGroup,
                          callback: loadValues,
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) =>
                  WorkoutGroupCreatePage());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() => GridView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 4, // Simulating 4 placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) =>
            WorkoutGroupCardPlaceholder(),
      );
}
