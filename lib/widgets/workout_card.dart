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
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        color: widget.workout.finish ? Colors.black54 : Colors.black12,
                        colorBlendMode:   BlendMode.darken ,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black45,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                widget.workout.exercise!.name,
                                style: widget.workout.finish
                                    ? const TextStyle(
                                        decoration:
                                            TextDecoration.lineThrough,
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
                                      color: Colors.red,
                                    ),
                                  ),
                                ]
                              : [],
                        ),
                      ),
                      if (widget.workout.method?.name != null)
                        Positioned(
                          bottom: 16,
                          right: MediaQuery.of(context).size.width - 110,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 4,
                            ),
                            child: Text(
                              widget.workout.method!.name!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      if (widget.workout.workoutSeries!.isNotEmpty)
                        ExpansionTile(
                          backgroundColor: Colors.black87,
                          collapsedBackgroundColor: Colors.black45,
                          textColor: Colors.white,
                          iconColor: Colors.blue,
                          title: Row(
                            children: [
                              const Icon(Icons.fitness_center,
                                  color: Colors.red),
                              const SizedBox(width: 5),
                              Text(
                                  '${widget.workout.workoutSeries?.length ?? 0} set(s)'),
                            ],
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  widget.workout.workoutSeries?.length ?? 0,
                              itemBuilder: (context, index) {
                                final series =
                                    widget.workout.workoutSeries?[index]!;
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text("${index+1}"),

                                      const SizedBox(width: 5),
                                      const Icon(Icons.repeat,
                                          color: Colors.red),
                                      const SizedBox(width: 5),
                                      Text("${series!.repetitions} reps"),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.monitor_weight,
                                          color: Colors.red),
                                      const SizedBox(width: 5),
                                      Text("${series!.weight} kgs"),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.timer,
                                          color: Colors.red),
                                      Text("${series!.rest} s"),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
