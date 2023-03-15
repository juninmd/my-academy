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
    Exercise(name: "Crucifixo Reto", image: "assets/images/crucifixo_reto.gif", sets: 3, reps: 10, weight: 100),
    Exercise(name: "Supino com halteres", image: "assets/images/supino_halteres.gif", sets: 3, reps: 8, weight: 120),
    Exercise(name: "Crucifixo Inclinado Com Halteres", image: "assets/images/crucifixo_inclinado_halteres.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Testa Barra W", image: "assets/images/tricepes_testa_barra_w.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Desenvolvimento com halteres", image: "assets/images/desenvolvimento_halteres.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Elevação Frontal", image: "assets/images/elevacao_frontal.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Remada Alta", image: "assets/images/remada_alta.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Elevação lateral", image: "assets/images/elevacao_lateral.gif", sets: 3, reps: 6, weight: 140),
   // Exercise(name: "Elevação Lateral Sentado Sem Apoio", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca de bíceps com barra W", image: "assets/images/rosca_biceps_barra_w.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca Concentrada", image: "assets/images/rosca_concentrada.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Rosca de martelo alternada", image: "assets/images/rosca_martelo_alternada.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Barra (polia alta)", image: "assets/images/tricepes_barra_polia_alta.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Corda", image: "assets/images/tricepes_corda.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Tríceps Francês Halteres", image: "assets/images/tricepes_frances_halter.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Cadeira Extensora", image: "assets/images/cadeira_extensora.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Leg Pres", image: "assets/images/leg_press.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Adutor de Coxas", image: "assets/images/adutor_coxas.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Hack", image: "assets/images/hack_machine.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Mesa Flexora", image: "assets/images/mesa_flexora.gif", sets: 3, reps: 6, weight: 140),
    Exercise(name: "Cadeira Flexora", image: "assets/images/cadeira_flexora.gif", sets: 3, reps: 6, weight: 140),
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
        width: 500,
        height: 500,
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
