import 'package:flutter/material.dart';
import 'package:my_academy/widgets/nav_drawer.dart';
import 'exercise_list.dart';
import 'models/exercise_group.dart';

class ExerciseGroupPage extends StatefulWidget {
  final String title;
  const ExerciseGroupPage({Key? key, required this.title}) : super(key: key);
  @override
  _ExerciseGroupState createState() => _ExerciseGroupState();
}

class _ExerciseGroupState extends State<ExerciseGroupPage> {
  List<ExerciseGroup> exerciseGroups = [    ExerciseGroup(name: "Pernas", image: "assets/images/leg_press.gif"),    ExerciseGroup(name: "Peitos", image: "assets/images/supino_halteres.gif"),    ExerciseGroup(name: "Ombros", image: "assets/images/elevacao_lateral.gif"),    ExerciseGroup(name: "Costas", image: "assets/images/tricepes_barra_polia_alta.gif"),  ];

  Set<int> _completedExerciseGroups = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: exerciseGroups.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExerciseListPage(title: exerciseGroups[index].name),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3.0),
                      ),
                      child: Image.asset(
                        exerciseGroups[index].image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    flex: 1,
                    child: ListTile(
                      title: Text(
                        exerciseGroups[index].name,
                        textAlign: TextAlign.center,
                        style: _completedExerciseGroups.contains(index)
                            ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red)
                            : TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
