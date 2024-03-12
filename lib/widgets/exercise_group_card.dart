import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/models/workout_group.dart';
import '../pages/workouts_page.dart';
import 'snackbar.dart';

class ExerciseGroupCard extends HookConsumerWidget {
  final WorkoutGroup workoutGroup;
  final bool alreadyWorkout;
  final Function callback;

  const ExerciseGroupCard({
    Key? key,
    required this.workoutGroup,
    required this.alreadyWorkout,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () async {
          if (alreadyWorkout) {
            snackBar(context, 'Você já treinou hoje');
            return;
          }
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => WorkoutsPage(
                workoutGroup: workoutGroup,
                callback: callback,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Image.asset(
              workoutGroup.image,
              fit: BoxFit.cover,
              width: double.infinity,
              color: Colors.black12,
              colorBlendMode: BlendMode.darken,
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      workoutGroup.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (alreadyWorkout)
              Positioned(
                  top: 8,
                  right: 8,
                  child: Chip(
                    backgroundColor: Colors.deepPurple,
                    label: const Text(
                      'Você já treinou hoje!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
