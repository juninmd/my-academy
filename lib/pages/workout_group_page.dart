import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/pages/workout_group_create_page.dart';

import '../stores/workout_group_store.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/loading.dart';

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
    }, [idUser]);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Card(
                color: Colors.deepPurple,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
              if (store.workoutGroups.isEmpty && !store.isLoading)
                Container(
                  padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Image.asset('assets/images/stickers/treino.png'),
                        SizedBox(height: 10),
                        Chip(
                          backgroundColor: Colors.white,
                          label: Text(
                            'Você não tem nenhum treino cadastrado :(',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else // Se houver treinos cadastrados, adiciona um Expanded para ocupar o espaço restante
                Expanded(
                  child: ListView.builder(
                    itemCount: store.workoutGroups.length,
                    itemBuilder: (BuildContext context, int index) {
                      final workoutGroup = store.workoutGroups[index];
                      return WorkoutGroupCard(
                        alreadyWorkout: false,
                        workoutGroup: workoutGroup,
                        callback: () {
                          store.loadValues(idUser);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
          if (store.isLoading) // Adiciona o widget de loading sobreposto
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: LoadingWidget(),
              ),
            ),
          if (!store.isLoading)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          WorkoutGroupCreatePage(idUser, null),
                    ),
                  ).then((_) {
                    store.loadValues(idUser);
                  });
                },
                child: Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }
}
