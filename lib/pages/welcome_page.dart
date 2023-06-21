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
            expandedHeight: size.height * 0.23,
            pinned: false,
            floating: false,
            centerTitle: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    "assets/images/bg2.jpg",
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.8),
                    colorBlendMode: BlendMode.darken,
                  ),
                  if (!store.isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(store.personal!.photoUrl),
                            ),
                            title: Text(
                              store.me.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Último treino',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Text(
                              '${store.lastSession!.workoutsGroups!.name} - ${DateFormat('dd/MM/yyyy').format(store.lastSession!.date.toUtc())}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sequência de ${store.exerciseFrequency} treino(s)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (store.personal != null)
                            Text(
                              'Personal: ${store.personal!.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (store.isLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
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
              color: Colors.black.withOpacity(0.9),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  if (store.students.isNotEmpty) const SizedBox(height: 10),
                  if (store.students.isNotEmpty)
                    const Text(
                      'Meus alunos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (store.students.isNotEmpty) const SizedBox(height: 10),
                  if (store.students.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: store.students.length,
                        itemBuilder: (context, index) {
                          final student = store.students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(student.photoUrl),
                            ),
                            title: Text(student.name),
                          );
                        },
                      ),
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
  WorkoutSession? lastSession;
  User me = User(id: idUser, name: '', email: '', photoUrl: '');
  User? personal;
  List<User> students = [];
  bool alreadyWorkout = false;
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      workoutSummary = await getWorkoutSummary(idUser);
      if (workoutSummary != null) {
        exerciseFrequency = workoutSummary!.counter;
        me = workoutSummary!.user!;
        students = workoutSummary!.students!;
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
