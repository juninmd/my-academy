import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../dto/workout-summary.dart';
import '../services/my_academy/workout_session_api.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

final welcomePageStoreProvider =
    ChangeNotifierProvider((ref) => WelcomePageStore());

class WelcomePage extends HookConsumerWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WelcomePageStore store = ref.watch(welcomePageStoreProvider);
    Size size = MediaQuery.of(context).size;

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            expandedHeight: size.height * 0.15,
            pinned: false,
            floating: false,
            centerTitle: true,
            backgroundColor: Colors.black,
            toolbarHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    "assets/images/bg1.jpg", // random
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.8),
                    colorBlendMode: BlendMode.darken,
                  ),
                  if (!store.isLoading)
                    Center(
                      child: Row(
                        children: [
                          const SizedBox(width: 60),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Último treino',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  store.lastWorkout,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Sequência de',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '${store.exerciseFrequency} treino(s)',
                                  style: const TextStyle(
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
                  if (store.isLoading) WorkoutGroupCardPlaceholder(),
                ],
              ),
            ),
          ),
        ],
        body: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/bg1.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.blue.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Treino do dia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (store.isLoading ||
                      store.workoutSummary?.workoutGroupOfDay == null)
                    WorkoutGroupCardPlaceholder()
                  else
                    WorkoutGroupCard(
                      alreadyWorkout: store.alreadyWorkout,
                      workoutGroup: store.workoutSummary!.workoutGroupOfDay!,
                      callback: store.loadValues,
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

class WelcomePageStore extends ChangeNotifier {
  WorkoutSummary? workoutSummary;
  int exerciseFrequency = 0;
  String lastWorkout = 'Nenhum';
  bool alreadyWorkout = false;
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      workoutSummary = await getWorkoutSummary(idUser);
      if (workoutSummary != null) {
        exerciseFrequency = workoutSummary!.counter;
        lastWorkout =
            workoutSummary!.lastSession?.workoutsGroups?.name ?? 'Nenhum';
        if (workoutSummary!.lastSession != null) {
          DateTime currentDay = DateTime.now();
          DateTime lastWorkoutDay = workoutSummary!.lastSession!.date;
          alreadyWorkout = DateFormat('yyyy-MM-dd').format(currentDay) ==
              DateFormat('yyyy-MM-dd').format(lastWorkoutDay);
        }
      }
    } catch (error) {
// Handle the error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
