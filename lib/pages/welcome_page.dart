import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

import '../constants.dart';
import '../dto/workout-summary.dart';
import '../services/my_academy/workout_session_api.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

part 'welcome_page.g.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final WelcomePageStore _store = WelcomePageStore();

  @override
  void initState() {
    super.initState();
    _store.loadValues();
  }

  WelcomePage({Key? key}) {
    _store.loadValues();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                  Observer(builder: (_) {
                    if (!_store.isLoading) {
                      return Center(
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
                                    _store.lastWorkout,
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
                                    '${_store.exerciseFrequency} treino(s)',
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
                      );
                    } else {
                      return WorkoutGroupCardPlaceholder();
                    }
                  }),
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
                  Observer(
                    builder: (_) {
                      if (_store.isLoading ||
                          _store.workoutSummary?.workoutGroupOfDay == null) {
                        return WorkoutGroupCardPlaceholder();
                      } else {
                        return WorkoutGroupCard(
                          alreadyWorkout: _store.alreadyWorkout,
                          workoutGroup:
                          _store.workoutSummary!.workoutGroupOfDay!,
                          callback: _store.loadValues,
                        );
                      }
                    },
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

class WelcomePageStore = _WelcomePageStoreBase with _$WelcomePageStore;

abstract class _WelcomePageStoreBase with Store {
  @observable
  WorkoutSummary? workoutSummary;

  @observable
  int exerciseFrequency = 0;

  @observable
  String lastWorkout = 'Nenhum';

  @observable
  bool alreadyWorkout = false;

  @observable
  bool isLoading = true;

  @action
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
    }
  }
}
