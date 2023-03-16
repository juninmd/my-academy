import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise.dart';
import 'package:my_academy/repository/exercise_repository.dart';
import 'package:my_academy/widgets/nav_drawer.dart';
import 'exercise_edit_page.dart';

class ExerciseListPage extends StatefulWidget {
  final String title;

  const ExerciseListPage({Key? key, required this.title}) : super(key: key);

  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  final Set<int> _completedExercises = {};
  List<Exercise> _exercises = exercises;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  List<Exercise> getExercises() {
    return exercises;
  }

  void filterExercises(String exerciseName) {
    if (exerciseName.isEmpty) {
      _exercises = getExercises();
    } else {
      _exercises = getExercises()
          .where((e) => e.name.toLowerCase().contains(exerciseName.toLowerCase()))
          .toList();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            icon: Icon(Icons.clear),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Procurar Exercício',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  filterExercises(value);
                });
              },
            ),
          ),
        ),
      ),

      body: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _exercises.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExerciseEditPage(exercise: _exercises[index]),
                  ),
                );
              },
              onLongPress: () async {
                await showDialog(
                  context: context,
                  builder: (_) => ImageDialog(image: _exercises[index].image, id: _exercises[index].id),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex:4,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3.0),
                      ),
                      child: Image.asset(
                        _exercises[index].image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      title: Text(
                        textAlign: TextAlign.center,
                        _exercises[index].name,
                        style: _completedExercises.contains(_exercises[index].id)
                            ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        )
                            : const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center),
                            SizedBox(width: 5),
                            Text("${_exercises[index].sets} sets"),
                            SizedBox(width: 5),
                            Icon(Icons.repeat),
                            SizedBox(width: 5),
                            Text("${_exercises[index].reps} reps"),
                            SizedBox(width: 5),
                            Icon(Icons.monitor_weight),
                            SizedBox(width: 5),
                            Text("${_exercises[index].weight} kgs"),
                          ],
                        ),
                  ),
              Expanded(
                flex: 1,
                child: Checkbox(
                  value: _completedExercises.contains(_exercises[index].id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _completedExercises.add(_exercises[index].id);
                      } else {
                        _completedExercises.remove(_exercises[index].id);
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.0,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5,
          mainAxisExtent: 200,
        ),
      ),
    );
  }
}

class ImageDialog extends StatefulWidget {
  final String image;
  final int id;

  const ImageDialog({Key? key, required this.image, required this.id}) : super(key: key);

  @override
  _ImageDialogState createState() => _ImageDialogState();
}
class _ImageDialogState extends State<ImageDialog> with SingleTickerProviderStateMixin {
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