import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise_group.dart';
import '../repository/exercise_group_repository.dart';

import '../repository/workouts_repository.dart';
import '../widgets/calories_progress_bar.dart';
import 'exercise_list_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  final String workoutImage = 'assets/images/draws/gym-boy.gif';
  late ExerciseGroup exerciseGroup = exerciseGroups[0];
  late int exerciseFrequency = 0;
  late String lastWorkout = '';
  late bool alreadWorkout = true;

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    await checkExerciseOfDay();
    int exerciseGroupIdIndex = await getExerciseIdOfDay();
    int frequency = await getExerciseFrequency();
    String lastWorkoutDate =
        (await getLastExerciseDate()) ?? 'Sem treinos';
    bool alreadWorkoutToday = await checkAlreadWorkoutToday();

    setState(() {
      lastWorkout = lastWorkoutDate;
      exerciseFrequency = frequency;
      exerciseGroup = exerciseGroups
          .firstWhere((element) => element.id == exerciseGroupIdIndex,
      orElse: () =>exerciseGroups[0]);
      alreadWorkout = alreadWorkoutToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              stretch: true,
              toolbarHeight: size.height * 0.1,
              collapsedHeight: size.height * 0.1,
              expandedHeight: size.height * 0.2,
              title: const Text(
                "Seja bem vindo",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                  stretchModes: <StretchMode>[
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(fit: StackFit.expand, children: <Widget>[
                    Image.asset(
                      "assets/images/bg2.jpg",
                      fit: BoxFit.cover,
                      color: const Color(0xaa212121),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ])),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Image.asset(
                      workoutImage,
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Último treino',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Text(
                            lastWorkout!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sequência de',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Text(
                            '$exerciseFrequency treinos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                'Treino do dia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      if(alreadWorkout){
                        _showAlreadWorkout(context);
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseListPage(
                                idGroup: exerciseGroup.id,
                                description: exerciseGroup.description),
                          ),
                        );
                        await loadValues();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            child: Image.asset(
                              exerciseGroup.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              color: alreadWorkout ? Colors.black54 : null,
                              colorBlendMode:
                              alreadWorkout ? BlendMode.darken : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 12.0, top: 10.0, right: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  textAlign: TextAlign.center,
                                  exerciseGroup.name,
                                  style: alreadWorkout
                                      ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )
                                      : const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Card(
                  elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Alimentação',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CaloriesProgressBar(consumed: 200,goal: 300, description: 'aa', unit: 'kcal')
                      ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlreadWorkout(BuildContext context) {
    const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        content: Text('Você já treinou hoje, vai descansar :)'),
      duration: Duration(seconds: 5), // Optional: Set a custom duration
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
