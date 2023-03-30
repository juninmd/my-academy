import 'package:flutter/material.dart';
import 'package:my_academy/repository/exercise_group_repository.dart';
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
                    background: Stack(fit: StackFit.expand, children: <Widget>[
                      Image.asset(
                        "assets/images/bg1.jpg",
                        fit: BoxFit.cover,
                        color: const Color(0xaa212121),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: 20,
                                  left: 12.0,
                                  top: 10.0,
                                  right: 12.0),
                              child: Text(
                                "BORA MONSTRO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100),
                              )),
                        ),
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
                        builder: (context) => ExerciseListPage(
                            idGroup: exerciseGroup.id,
                            description: exerciseGroup.description),
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
          )),
    );
  }
}
