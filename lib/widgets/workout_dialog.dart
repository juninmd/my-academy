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
    _tabController = TabController(
      length: widget.workout.method != null ? 3 : 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: Column(
          children: [
            Expanded(
              flex: 2,
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
              flex: 1,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.white,
                    controller: _tabController,
                    tabs: [
                      if (widget.workout.method != null)
                        Tab(
                          text: widget.workout.method!.name,
                          icon: Icon(Icons.accessibility, color: Colors.red),
                        ),
                      Tab(
                        text: 'Dicas',
                        icon: Icon(Icons.sports_mma, color: Colors.red),
                      ),
                      Tab(
                        text: 'Erros',
                        icon: Icon(Icons.block, color: Colors.red),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        if (widget.workout.method != null)
                          ListTile(
                            leading: Icon(Icons.emoji_events_rounded),
                            title: Text(widget.workout.method!.description),
                          ),
                        ListView.builder(
                          itemCount: widget.workout.exercise!.tips.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.info),
                              title: Text(widget.workout.exercise!.tips[index]),
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: widget.workout.exercise!.mistakes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.flag_outlined),
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
