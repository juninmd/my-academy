import 'package:flutter/material.dart';

import '../models/workout_group.dart';
import '../services/my_academy/workout_group_api.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

class WorkoutGroupPage extends StatefulWidget {
  const WorkoutGroupPage({Key? key}) : super(key: key);
  @override
  _WorkoutGroupState createState() => _WorkoutGroupState();
}

class _WorkoutGroupState extends State<WorkoutGroupPage> {
  late Future<List<WorkoutGroup>> _workoutGroupsFuture;

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    setState(() {
      _workoutGroupsFuture = getWorkoutGroups();
    });
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: const Text(
            "Meus Treinos",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
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
                          alreadWorkout: false,
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
      );

  Widget _buildLoadingState() =>
      GridView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 4, // Simulating 4 placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return WorkoutGroupCardPlaceholder();
        },
      );

}
