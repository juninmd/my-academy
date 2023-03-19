import 'package:flutter/material.dart';
import 'package:my_academy/repository/exercise_group_repository.dart';
import 'package:my_academy/widgets/nav_drawer.dart';
import 'exercise_list.dart';

class ExerciseGroupPage extends StatefulWidget {
  final String title;
  const ExerciseGroupPage({Key? key, required this.title}) : super(key: key);
  @override
  _ExerciseGroupState createState() => _ExerciseGroupState();
}

class _ExerciseGroupState extends State<ExerciseGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
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
          var exerciseGroup = exerciseGroups[index];
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
                        ExerciseListPage(idGroup: exerciseGroup.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3.0),
                      ),
                      child: Image.asset(
                        exerciseGroup.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    flex: 1,
                    child: ListTile(
                      title: Text(
                        exerciseGroup.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
