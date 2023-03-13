import 'package:flutter/material.dart';
import 'exercise.dart';
import 'exercise_edit_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino do dia',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: const ExerciseListPage(title: 'Treino do dia'),
    );
  }
}


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
        appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: _completedExercises.contains(index) ? Colors.grey[800] : Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseEditPage(exercise: exercises[index])));
              },
              child: Column(
                children: [
                  Image.asset(exercises[index].image),
                  ListTile(
                    title: Text(exercises[index].name),
                    subtitle: Text("${exercises[index].sets} sets x ${exercises[index].reps} reps x ${exercises[index].weight} lbs"),
                    trailing: Checkbox(
                      value: _completedExercises.contains(index),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            _completedExercises.add(index);
                          } else {
                            _completedExercises.remove(index);
                          }
                        });
                      },
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
