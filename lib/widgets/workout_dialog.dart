import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutDialog extends StatefulWidget {
  final Workout workout;

  const WorkoutDialog({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutDialogState createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<WorkoutDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    var length = 2;
    if (widget.workout.method != null) {
      length++;
    }
    if (widget.workout.workoutSeries!.isNotEmpty) {
      length++;
    }
    _tabController = TabController(
      length: length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.workout.exercise!.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage(widget.workout.exercise!.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.white,
                    controller: _tabController,
                    tabs: [
                      if (widget.workout.workoutSeries!.isNotEmpty)
                        Tab(
                          icon: Icon(Icons.expand, color: Colors.deepPurple),
                        ),
                      if (widget.workout.method != null)
                        Tab(
                          icon: Icon(Icons.accessibility,
                              color: Colors.deepPurple),
                        ),
                      Tab(
                        icon: Icon(Icons.info, color: Colors.deepPurple),
                      ),
                      Tab(
                        icon: Icon(Icons.block, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        if (widget.workout.workoutSeries!.isNotEmpty)
                          ListView.builder(
                            itemCount:
                                widget.workout.workoutSeries?.length ?? 0,
                            itemBuilder: (context, index) {
                              final series =
                                  widget.workout.workoutSeries?[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: ListBody(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${index + 1}"),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.repeat,
                                          color: Colors.deepPurple),
                                      const SizedBox(width: 5),
                                      Text("${series!.repetitions} reps"),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.monitor_weight,
                                          color: Colors.deepPurple),
                                      const SizedBox(width: 5),
                                      Text("${series.weight} kgs"),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.timer,
                                          color: Colors.deepPurple),
                                      Text("${series.rest} s"),
                                    ],
                                  ),
                                ]),
                              );
                            },
                          ),
                        if (widget.workout.method != null)
                          Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.emoji_events_rounded),
                                title: Text(widget.workout.method!.name),
                              ),
                              ListTile(
                                title: Text(widget.workout.method!.description),
                              ),
                            ],
                          ),
                        ListView.builder(
                          itemCount: widget.workout.exercise!.tips.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(widget.workout.exercise!.tips[index]),
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: widget.workout.exercise!.mistakes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  widget.workout.exercise!.mistakes[index]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
