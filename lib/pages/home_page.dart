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
import '../widgets/workout_group_card_placeholder.dart';
import 'gym_calendar_page.dart';

final homePageStoreProvider = ChangeNotifierProvider((ref) => HomePageStore());

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePageStore store = ref.watch(homePageStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

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
                  'assets/images/bg1.jpg',
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
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Treino do dia",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (store.isLoading)
            Center(
              child: WorkoutGroupCardPlaceholder(),
            )
          else if (!store.isLoading)
            Container(
              padding: const EdgeInsets.only(
                  top: 80, left: 10, right: 10), // Espaço acima dos treinos
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
                          // Inserir a imagem aqui (por exemplo, usando o widget Image.asset)
                          Image.asset('assets/images/stickers/treino2.png'),
                          // Espaço entre a imagem e o texto
                          SizedBox(height: 10),
                          // Texto que descreve a imagem
                          Chip(
                            backgroundColor: Colors
                                .white, // Use white background for contrast
                            label: Text(
                              'Você não tem nenhum treino cadastrado :(',
                              style: TextStyle(
                                  fontSize:
                                  15, // Slightly larger font size for better readability
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .deepPurple), // Inverse text color for the chip
                            ),
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
                    color: Colors.deepPurple, // Modern color scheme
                    elevation: 4, // Add some elevation for a nice shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Rounded corners for a modern look
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align content to the left
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
                                'Último treino',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      12, // Slightly larger font size for better readability
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (store.lastSession?.workoutsGroups?.name !=
                                      null &&
                                  store.lastSession?.date != null)
                                Chip(
                                  backgroundColor: Colors
                                      .white, // Use white background for contrast
                                  label: Text(
                                    '${store.lastSession!.workoutsGroups!.name} - ${DateFormat('dd/MM/yyyy').format(store.lastSession!.date.toUtc())}',
                                    style: TextStyle(
                                        fontSize:
                                            15, // Slightly larger font size for better readability
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .deepPurple), // Inverse text color for the chip
                                  ),
                                ),
                              if (store.lastSession?.workoutsGroups?.name ==
                                  null)
                                Chip(
                                  backgroundColor: Colors
                                      .white, // Use white background for contrast
                                  label: Text(
                                    'Você não treinou :(',
                                    style: TextStyle(
                                        fontSize:
                                            15, // Slightly larger font size for better readability
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .deepPurple), // Inverse text color for the chip
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                              height: 16), // Increased spacing between sections
                          Row(
                            children: [
                              Icon(
                                Icons.timeline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sequência de ${store.exerciseFrequency} treino(s)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Visualizar Histórico',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GymCalendarPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.calendar_month),
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
                                    fontSize:
                                        12, // Adjusted font size for personal info
                                    fontWeight: FontWeight.bold,
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
    );
  }
}

class HomePageStore extends ChangeNotifier {
  WorkoutSummary? workoutSummary;
  int exerciseFrequency = 0;
  WorkoutSession? lastSession;
  User me = User(id: idUser, name: '', email: '', photoUrl: '');
  User? personal;
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
