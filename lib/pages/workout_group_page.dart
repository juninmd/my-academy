import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/pages/workout_group_create_page.dart';

import '../stores/workout_group_store.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

final workoutGroupStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupStore());

class WorkoutGroupPage extends HookConsumerWidget {
  const WorkoutGroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, []);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.05,
            pinned: true,
            floating: true,
            title: const Text(
              "Meus Treinos",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    "assets/images/bg1.jpg", // random
                    fit: BoxFit.cover,
                    color: const Color(0xaa212121),
                    colorBlendMode: BlendMode.darken,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: store.isLoading
            ? _buildLoadingState()
            : GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: store.workoutGroups.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 32.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final workoutGroup = store.workoutGroups[index];
                  return WorkoutGroupCard(
                      alreadyWorkout: false,
                      workoutGroup: workoutGroup,
                      callback: store.loadValues);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => WorkoutGroupCreatePage());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() => GridView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 4, // Simulating 4 placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (BuildContext context, int index) =>
            WorkoutGroupCardPlaceholder(),
      );
}
