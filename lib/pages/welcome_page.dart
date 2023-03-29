import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise_group.dart';

import 'exercise_list_page.dart';

class WelcomePage extends StatefulWidget {
  final String workoutImage;
  final ExerciseGroup exerciseGroup;
  final ExerciseGroup favoriteExerciseGroup;

  const WelcomePage({
    Key? key,
    required this.workoutImage,
    required this.exerciseGroup,
    required this.favoriteExerciseGroup,
  }) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, boa noite!'),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      widget.workoutImage,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(width: 80),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sequência de',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.purple,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Text(
                          '20 treinos',
                          style: TextStyle(
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
            SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExerciseListPage(idGroup: widget.exerciseGroup.id, description: widget.exerciseGroup.description),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: ClipRRect(
                          child: Image.asset(
                            widget.exerciseGroup.image,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Treino do dia',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.exerciseGroup.name,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.exerciseGroup.description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
