import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'workout_dialog.dart';

class WorkoutCard extends StatefulWidget {
  final Workout workout;
  final Function(Workout) onWorkoutStatusChanged;

  const WorkoutCard({
    Key? key,
    required this.workout,
    required this.onWorkoutStatusChanged,
  }) : super(key: key);

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  void callback(int weight, int reps, int sets) {
    setState(() {});
  }

  void _toggleFinish() {
    setState(() {
      widget.workout.finish = !widget.workout.finish;
      widget
          .onWorkoutStatusChanged(widget.workout); // Call the callback function
    });
  }

  @override
  Widget build(BuildContext context) => Card(

        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Column(
          children: [
            InkWell(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(_toggleFinish);
                    },
                    onLongPress: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => WorkoutDialog(workout: widget.workout),
                      );
                    },
                    child: Stack(
                      children: [
                        Image.asset(
                          widget.workout.exercise!.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          color: widget.workout.finish
                              ? Colors.black54
                              : Colors.black12,
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
                                  widget.workout.method?.name == null
                                      ? widget.workout.exercise!.name
                                      : "${widget.workout.exercise!.name} (${widget.workout.method!.name})",
                                  style: widget.workout.finish
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
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 16,
                          left: MediaQuery.of(context).size.width - 80,
                          child: Row(
                            children: widget.workout.finish
                                ? [
                                    const SizedBox(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ]),
            ),

          ],
        ),
      );
}
