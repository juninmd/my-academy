import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/students/presentation/pages/student_add_page.dart';
import '../../features/students/presentation/pages/students_page.dart';
import '../../features/workouts/domain/entities/exercise_entity.dart';
import '../../features/workouts/domain/entities/workout_group_entity.dart';
import '../../features/workouts/presentation/pages/analytics_page.dart';
import '../../features/workouts/presentation/pages/exercise_library_page.dart';
import '../../features/workouts/presentation/pages/exercise_stats_page.dart';
import '../../features/workouts/presentation/pages/workout_create_page.dart';
import '../../features/workouts/presentation/pages/workout_details_page.dart';
import '../../features/workouts/presentation/pages/workout_groups_page.dart';
import '../../features/workouts/presentation/pages/workout_player_page.dart';
import '../../features/workouts/presentation/pages/workout_history_page.dart';

part 'app_router.g.dart';

final _key = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _key,
    initialLocation: '/login',
    refreshListenable: ValueNotifier(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const WorkoutHistoryPage(),
      ),
      GoRoute(
        path: '/exercise-details',
        builder: (context, state) {
          if (state.extra is! ExerciseEntity) {
            return const Scaffold(
              body: Center(child: Text('Erro: Exercício não encontrado.')),
            );
          }
          final exercise = state.extra as ExerciseEntity;
          return ExerciseStatsPage(exercise: exercise);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                HomeShellPage(navigationShell: navigationShell),
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardPage(),
                routes: [
                  GoRoute(
                    path: 'exercises',
                    builder: (context, state) => const ExerciseLibraryPage(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Workouts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const WorkoutGroupsPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      final group = state.extra as WorkoutGroupEntity?;
                      return WorkoutCreatePage(initialGroup: group);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return WorkoutDetailsPage(groupId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'player',
                        builder: (context, state) {
                          final id =
                              int.tryParse(state.pathParameters['id'] ?? '') ??
                              0;
                          return WorkoutPlayerPage(groupId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),

          // Branch 3: Students
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/students',
                builder: (context, state) => const StudentsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const StudentAddPage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
