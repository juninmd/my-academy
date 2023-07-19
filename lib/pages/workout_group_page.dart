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
  final int idUser;
  final String? name;
  const WorkoutGroupPage(this.idUser, this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);

    useEffect(() {
      store.loadValues(idUser);
      return null;
    }, []);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.9),
              BlendMode.color,
            ),
            child: Container(
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/bg2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.deepPurple, // Modern color scheme
              elevation: 4, // Add some elevation for a nice shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Rounded corners for a modern look
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Treinos ${name ?? ''}",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (store.isLoading)
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: _buildLoadingState(),
              ),
            )
          else if (store.workoutGroups.isEmpty)
            Container(
              padding: const EdgeInsets.only(top: 120), // Espaço acima dos treinos
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Image.asset('assets/images/stickers/treino.png'),
                    SizedBox(height: 10),
                    Text(
                      'Você não tem nenhum treino cadastrado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (!store.isLoading)
              Container(
                padding: const EdgeInsets.only(top: 80,left: 10,right: 10), // Espaço acima dos treinos
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: store.workoutGroups.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6.0,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  WorkoutGroupCreatePage(idUser));
        },
        child: Icon(Icons.add_box),
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
