import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/models/workout_group.dart';
import '../pages/workouts_page.dart';
import 'snackbar.dart';

class WorkoutGroupCard extends HookConsumerWidget {
  final WorkoutGroup workoutGroup;
  final bool alreadyWorkout;
  final Function callback;

  const WorkoutGroupCard({
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
          // Adicionado o Stack envolvendo o Column
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 160, // Altura desejada para o container
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(workoutGroup
                          .image), // Substitua pelo caminho da sua imagem
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Text(
                    workoutGroup.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                        'Você já treinou!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
