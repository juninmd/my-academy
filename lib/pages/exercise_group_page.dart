import 'package:flutter/material.dart';
import 'package:my_academy/repository/exercise_group_repository.dart';
import '../models/exercise_group.dart';
import '../widgets/exercise_group_card.dart';
import 'exercise_list_page.dart';

class ExerciseGroupPage extends StatefulWidget {
  const ExerciseGroupPage({Key? key}) : super(key: key);
  @override
  _ExerciseGroupState createState() => _ExerciseGroupState();
}

class _ExerciseGroupState extends State<ExerciseGroupPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: NestedScrollView(
            floatHeaderSlivers: false,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  toolbarHeight: size.height * 0.1,
                  collapsedHeight: size.height * 0.1,
                  expandedHeight: size.height * 0.2,
                  title: const Text(
                    "Meus Treinos",
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.black,
                  flexibleSpace: FlexibleSpaceBar(
                      stretchModes: <StretchMode>[
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background:
                          Stack(fit: StackFit.expand, children: <Widget>[
                        Image.asset(
                          "assets/images/bg4.jpg",
                          fit: BoxFit.cover,
                          color: const Color(0xaa212121),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ])),
                ),
              ];
            },
            body: GridView.builder(
                padding: const EdgeInsets.only(top: 8), // <
                shrinkWrap: true,
                itemCount: exerciseGroups.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final exerciseGroup = exerciseGroups[index];
                  return ExerciseGroupCard(
                      alreadWorkout: false, exerciseGroup: exerciseGroup);
                })));
  }
}
