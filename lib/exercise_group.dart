import 'package:flutter/material.dart';
import 'package:my_academy/widgets/nav_drawer.dart';
import 'exercise_list.dart';
import 'models/exercise_group.dart';

class ExerciseGroupPage extends StatefulWidget {
  final String title;
  const ExerciseGroupPage({super.key, required this.title});
  @override
  _ExerciseGroupState createState() => _ExerciseGroupState();
}

class _ExerciseGroupState extends State<ExerciseGroupPage> {
  List<ExerciseGroup> ExerciseGroups = [
    ExerciseGroup(name: "Pernas", image: "assets/images/deadlift.gif"),
    ExerciseGroup(name: "Peitos", image: "assets/images/deadlift.gif"),
    ExerciseGroup(name: "Ombros", image: "assets/images/deadlift.gif"),
    ExerciseGroup(name: "Costas", image: "assets/images/deadlift.gif"),
  ];

  Set<int> _completedExerciseGroups = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
        appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: ExerciseGroups.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color:  Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseListPage(title: ExerciseGroups[index].name)));
              },
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                children: [
                  Image.asset(ExerciseGroups[index].image, fit: BoxFit.fitWidth,height: 110, width: 300),
                  ListTile(
                    title: Text(ExerciseGroups[index].name,
                        textAlign: TextAlign.center,
                        style:  _completedExerciseGroups.contains(index) ? const TextStyle(decoration: TextDecoration.lineThrough,color: Colors.red ):  null),
                  ),
                ],
              ),
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 5,
          mainAxisExtent: 160,
        ),
      ),
    );
  }
}
