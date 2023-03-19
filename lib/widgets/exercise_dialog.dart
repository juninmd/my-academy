import 'package:flutter/material.dart';

class ExerciseDialog extends StatefulWidget {
  final String image;
  final int id;

  const ExerciseDialog({Key? key, required this.image, required this.id})
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
      child: Container(
        width: 500,
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        text: 'Dicas',
                      ),
                      Tab(
                        text: 'Músculos',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'As dicas vão aqui',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Músculos usados',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
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
