import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../dto/workout-summary.dart';
import '../models/user.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';
import '../widgets/exercise_group_card.dart';
import 'gym_calendar_page.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'students_page.dart';

final homePageStoreProvider = ChangeNotifierProvider((ref) => HomePageStore());

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePageStore store = ref.watch(homePageStoreProvider);

    useEffect(() {
      store.loadValues(FireBaseUser!.uid);
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Treino do dia'),
          backgroundColor: Colors.deepPurple,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configurações'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.person_off),
                    title: Text('Fazer Log-out'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value:3,
                  child: ListTile(
                    leading: Icon(Icons.people_alt_rounded),
                    title: Text('Alunos'),
                  ),
                ),
              ],
              onSelected: (int value) async {
                switch (value) {
                  case 1:
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                    break;
                  case 2:
                    store.logout(context);
                    break;
                  case 3:
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentsPage(),
                      ),
                    );
                    break;
                }
              },
            )
          ]),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // Animation duration
        curve: Curves.easeInOutCubic, // Animation curve
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white12,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${FireBaseUser!.displayName}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      if (store.isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (!store.isLoading)
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (store.workoutSummary?.workoutGroupOfDay ==
                                  null)
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 10, right: 10),
                                  child: Card(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Nenhum treino programado para hoje',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ExerciseGroupCard(
                                  alreadyWorkout: store.alreadyWorkout,
                                  workoutGroup:
                                      store.workoutSummary!.workoutGroupOfDay!,
                                  callback: () {
                                    store.loadValues(FireBaseUser!.uid);
                                  },
                                ),
                              Card(
                                color: Colors.deepPurple,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.fitness_center,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Último treino:',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          if (store.lastSession?.workoutsGroups
                                                      ?.name !=
                                                  null &&
                                              store.lastSession?.date != null)
                                            Text(
                                              '${store.lastSession!.workoutsGroups!.name} - ${DateFormat('dd/MM/yyyy').format(store.lastSession!.date.toUtc())}',
                                            ),
                                          if (store.lastSession?.workoutsGroups
                                                  ?.name ==
                                              null)
                                            const Text(
                                              'Nenhum',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: Colors.white,
                                          ),
                                          TextButton(
                                            child: const Text(
                                                'Visualizar Histórico'),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const GymCalendarPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.security,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            store.exerciseFrequency == 0
                                                ? 'Você não realizou algum treino ainda'
                                                : 'Sequência de ${store.exerciseFrequency} dia(s)',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (store.personal != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Personal: ${store.personal!.name}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageStore extends ChangeNotifier {
  WorkoutSummary? workoutSummary;
  int exerciseFrequency = 0;
  WorkoutSession? lastSession;
  Users me = Users(id: FireBaseUser!.uid, name: '', email: '', photoUrl: '');
  Users? personal;
  bool alreadyWorkout = false;
  bool isLoading = true;

  logout(context) {
    FireBaseUser = null;
    final auth = FirebaseAuth.instance;
    auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> loadValues(String idUser) async {
    try {
      isLoading = true;
      workoutSummary = await getWorkoutSummary(idUser);
      if (workoutSummary != null) {
        exerciseFrequency = workoutSummary!.counter;
        personal = workoutSummary?.personal;
        if (workoutSummary!.lastSession != null) {
          lastSession = workoutSummary!.lastSession!;
          DateTime currentDay = DateTime.now();
          DateTime lastWorkoutDay = workoutSummary!.lastSession!.date;
          alreadyWorkout = DateFormat('yyyy-MM-dd').format(currentDay) ==
              DateFormat('yyyy-MM-dd').format(lastWorkoutDay);
        }
      }
    } catch (error) {
      workoutSummary = null;
      exerciseFrequency = 0;
      alreadyWorkout = false;
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
