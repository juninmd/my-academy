import 'package:flutter/material.dart';

import '../pages/exercise_edit_page.dart';
import '../models/exercise.dart';
import 'exercise_dialog.dart';

class ExerciseCardPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseCardPage({Key? key, required this.exercise}) : super(key: key);

  @override
  _ExerciseCardPageState createState() => _ExerciseCardPageState();
}

class _ExerciseCardPageState extends State<ExerciseCardPage> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseEditPage(exercise: widget.exercise),
            ),
          );
        },
        onLongPress: () async {
          await showDialog(
            context: context,
            builder: (_) => ExerciseDialog(
                exercise: widget.exercise),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3.0),
                ),
                child: Image.asset(
                  widget.exercise.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 5),
                    Text(
                      textAlign: TextAlign.center,
                      widget.exercise.name,
                      style: widget.exercise.finish
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            )
                          : const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                    Checkbox(
                      value: widget.exercise.finish,
                      onChanged: (bool? value) {
                        setState(() {
                          widget.exercise.finish = value ?? false;
                        });
                      },
                    ),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, color: Colors.red),
                  const SizedBox(width: 5),
                  Text("${widget.exercise.sets} sets"),
                  const SizedBox(width: 5),
                  const Icon(Icons.repeat, color: Colors.red),
                  const SizedBox(width: 5),
                  Text("${widget.exercise.reps} reps"),
                  const SizedBox(width: 5),
                  const Icon(Icons.monitor_weight, color: Colors.red),
                  const SizedBox(width: 5),
                  Text("${widget.exercise.weight} kgs"),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.red),
                    iconSize: 20,
                    onPressed: () {
                      // Ao pressionar o botão, navega para a página de edição passando o exercício como argumento
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExerciseEditPage(exercise: widget.exercise),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
