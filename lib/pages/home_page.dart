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

final homePageStoreProvider = ChangeNotifierProvider((ref) => HomePageStore());

class HomePage extends HookConsumerWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePageStore store = ref.watch(homePageStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

    final children2 = [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.black],
          ),
        ),
      ),
      Positioned(
        top: 15,
        left: 10,
        right: 10,
        child: Card(
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
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  "Treino do dia de ${user?.displayName}",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
      if (store.isLoading)
        Center(
          child: CircularProgressIndicator(),
        )
      else if (!store.isLoading)
        SingleChildScrollView(
          // Adicionado SingleChildScrollView
          child: Container(
            padding: const EdgeInsets.only(top: 80, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (store.workoutSummary?.workoutGroupOfDay == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Image.asset('assets/images/stickers/treino2.png',
                            width: 200, height: 200),
                        SizedBox(height: 20),
                        Text(
                          'Nenhum treino programado para hoje',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  WorkoutGroupCard(
                    alreadyWorkout: store.alreadyWorkout,
                    workoutGroup: store.workoutSummary!.workoutGroupOfDay!,
                    callback: store.loadValues,
                  ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.deepPurple,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Último treino:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (store.lastSession?.workoutsGroups?.name !=
                                    null &&
                                store.lastSession?.date != null)
                              Text(
                                '${store.lastSession!.workoutsGroups!.name} - ${DateFormat('dd/MM/yyyy').format(store.lastSession!.date.toUtc())}',
                              ),
                            if (store.lastSession?.workoutsGroups?.name == null)
                              Text(
                                'Nenhum',
                                style: TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                            ),
                            TextButton(
                              child: const Text('Visualizar Histórico'),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GymCalendarPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.exerciseFrequency == 0
                                  ? 'Você não realizou algum treino ainda'
                                  : 'Sequência de ${store.exerciseFrequency} dia(s)',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (store.personal != null)
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Personal: ${store.personal!.name}',
                                style: TextStyle(
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
        ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: children2,
      ),
    );
  }
}

class HomePageStore extends ChangeNotifier {
  WorkoutSummary? workoutSummary;
  int exerciseFrequency = 0;
  WorkoutSession? lastSession;
  Users me = Users(id: idUser, name: '', email: '', photoUrl: '');
  Users? personal;
  bool alreadyWorkout = false;
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      workoutSummary = await getWorkoutSummary(idUser);
      if (workoutSummary != null) {
        exerciseFrequency = workoutSummary!.counter;
        me = workoutSummary!.user!;
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
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
