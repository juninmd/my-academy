import 'package:flutter/material.dart';
import 'package:my_academy/widgets/nav_drawer.dart';
import 'models/exercise.dart';
import 'exercise_edit_page.dart';

class ExerciseListPage extends StatefulWidget {
  final String title;
  const ExerciseListPage({super.key, required this.title});
  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  List<Exercise> exercises = [
    Exercise(name: "Crucifixo Reto", image: "assets/images/bench_press.gif", sets: 3, reps: 10, weight: 100),
    Exercise(name: "Supino com halteres", image: "assets/images/squat.gif", sets: 3, reps: 8, weight: 120),
    Exercise(name: "Crucifixo Inclinado Com Halteres", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Testa Barra W", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Desenvolvimento com halteres", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Elevação Frontal", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Remada Alta", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Elevação lateral", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Elevação Lateral Sentado Sem Apoio", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca de bíceps com barra", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca Concentrada", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca de martelo alternada", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Barra", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Francês Halteres", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Testa Barra W", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
  ];

  Set<int> _completedExercises = {};

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
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color:  Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseEditPage(exercise: exercises[index])));
              },
              onLongPress: ()async{
                await showDialog(
                    context: context,
                    builder: (_) => ImageDialog(image: exercises[index].image)
                );
              },
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                children: [
                  Image.asset(exercises[index].image, fit: BoxFit.fitWidth,height: 110, width: 300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(exercises[index].name,
                              style:  _completedExercises.contains(index) ? const TextStyle(decoration: TextDecoration.lineThrough,color: Colors.red ):  null),
                          controlAffinity: ListTileControlAffinity.platform,
                          value: _completedExercises.contains(index),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _completedExercises.add(index);
                              } else {
                                _completedExercises.remove(index);
                              }
                            });
                          }
                      ),
                  )]),
                  ListTile(
                    subtitle: Text("${exercises[index].sets} sets x ${exercises[index].reps} repetições x ${exercises[index].weight} kgs"),
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
          mainAxisExtent: 260,
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget  {
  final String image;

  const ImageDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage(image),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }
}
