import 'package:flutter/material.dart';

import '../pages/exercise_edit_page.dart';
import '../models/exercise.dart';
import 'exercise_dialog.dart';

class ExerciseCardPage extends StatefulWidget {
  final Exercise exercise;
  final Function(Exercise) onExerciseStatusChanged;

  const ExerciseCardPage(
      {Key? key, required this.exercise, required this.onExerciseStatusChanged})
      : super(key: key);

  @override
  _ExerciseCardPageState createState() => _ExerciseCardPageState();
}

class _ExerciseCardPageState extends State<ExerciseCardPage> {
  void callback(int weight, int reps, int sets) {
    setState(() {
      widget.exercise.weight = weight;
      widget.exercise.reps = reps;
      widget.exercise.sets = sets;
    });
  }

  void _toggleFinish() {
    setState(() {
      widget.exercise.finish = !widget.exercise.finish;
      widget.onExerciseStatusChanged(
          widget.exercise); // Call the callback function
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3.0),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _toggleFinish();
                    });
                  },
                  onLongPress: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => ExerciseDialog(exercise: widget.exercise),
                    );
                  },
                  child: Stack(children: [
                    Image.asset(
                      widget.exercise.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: widget.exercise.finish ? Colors.black54 : null,
                      colorBlendMode:
                          widget.exercise.finish ? BlendMode.darken : null,
                    ),
                    Positioned(
                      bottom: 16,
                      left: MediaQuery.of(context).size.width - 80,
                      child: Row(
                        children: widget.exercise.finish
                            ? [
                                const SizedBox(
                                    child:
                                        Icon(Icons.check, color: Colors.red)),
                              ]
                            : [],
                      ),
                    ),
                    Positioned(
                        bottom: 16,
                        right: MediaQuery.of(context).size.width - 110,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Text(
                            'DropSet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )),
                  ]),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      widget.exercise.finish = !widget.exercise.finish;
                    });
                  },
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                            : const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                      ),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  // Ao pressionar o botão, navega para a página de edição passando o exercício como argumento
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseEditPage(
                          exercise: widget.exercise, callback: callback),
                    ),
                  );
                },
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
