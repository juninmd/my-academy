import 'package:flutter/material.dart';
import '../models/workout_group.dart';
import 'confirm_finish_workout.dart';

class FinishWorkoutButton extends StatelessWidget {
  final WorkoutGroup workoutGroup;
  Function callback;

  FinishWorkoutButton(
      {super.key, required this.callback, required this.workoutGroup});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        onPressed: () async {
          await ConfirmFinishWorkout(context, workoutGroup, callback);
        },
        label: const Text(
          "Finalizar treino",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      );
}
