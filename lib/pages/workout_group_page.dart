import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/pages/workout_group_create_page.dart';

import '../stores/workout_group_store.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/loading.dart';

class WorkoutGroupPage extends HookConsumerWidget {
  final String idUser;
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
      appBar: AppBar(
        title: const Text('Treinos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [

            Column(
              children: [
                if (store.workoutGroups.isEmpty && !store.isLoading)
                  Container(
                    padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Você ainda não cadastrou algum treino',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else // Se houver treinos cadastrados, adiciona um Expanded para ocupar o espaço restante
                  Expanded(
                    child: ListView.builder(
                      itemCount: store.workoutGroups.length,
                      itemBuilder: (BuildContext context, int index) {
                        final workoutGroup = store.workoutGroups[index];
                        return ExerciseGroupCard(
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
                bottom: 8,
                right: 16,
                width: 120,
                child: FloatingActionButton.extended(
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
                  label:const Text(
                    "Novo treino",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
