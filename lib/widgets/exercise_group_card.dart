import 'package:flutter/material.dart';
import 'package:my_academy/models/workout_group.dart';

import '../pages/workouts_page.dart';

class WorkoutGroupCard extends StatelessWidget {
  final WorkoutGroup workoutGroup;
  final bool alreadyWorkout;
  final Function callback;

  const WorkoutGroupCard(
      {Key? key, required this.workoutGroup, required this.alreadyWorkout,
        required this.callback
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () async {
            if (alreadyWorkout) {
              _showAlreadWorkout(context);
              callback();
              return;
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WorkoutsPage(workoutGroup: workoutGroup, callback: callback),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Stack(children: [
                    Image.asset(
                      workoutGroup.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: alreadyWorkout ? Colors.black45 : null,
                      colorBlendMode: alreadyWorkout ? BlendMode.darken : null,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black45,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Text(
                              workoutGroup.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (alreadyWorkout)
                      Positioned(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 4,
                              ),
                              child: const Text(
                                'Você já treinou!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );

  void _showAlreadWorkout(BuildContext context) {
    const SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      content: Text('Você já treinou hoje, vai descansar :)'),
      duration: Duration(seconds: 5), // Optional: Set a custom duration
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
