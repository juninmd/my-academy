import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseDialog extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDialog({Key? key, required this.exercise})
      : super(key: key);

  @override
  _ExerciseDialogState createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<ExerciseDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(widget.exercise.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black,
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      text: 'Dicas',
                      icon: Icon(Icons.sports_mma,color: Colors.red),
                    ),
                    Tab(
                      text: 'Erros Comuns',
                      icon: Icon(Icons.block,color: Colors.red),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:   [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: widget.exercise.tips.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.info),
                              title: Text(widget.exercise.tips[index]),
                            );
                          },
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: widget.exercise.errors.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.flag_outlined),
                                title: Text(widget.exercise.errors[index]),
                              );
                            },
                          )
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
}
