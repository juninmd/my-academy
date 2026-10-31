import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/workouts/domain/entities/exercise_entity.dart';
import '../../features/workouts/domain/entities/workout_group_entity.dart';
import '../../features/workouts/presentation/pages/analytics_page.dart';
import '../../features/workouts/presentation/pages/exercise_library_page.dart';
import '../../features/workouts/presentation/pages/exercise_details_page.dart';
import '../../features/workouts/presentation/pages/workout_create_page.dart';
import '../../features/workouts/presentation/pages/workout_details_page.dart';
import '../../features/workouts/presentation/pages/workout_groups_page.dart';
import '../../features/workouts/presentation/pages/workout_player_page.dart';
import '../../features/workouts/presentation/pages/workout_history_page.dart';
import '../../features/progress/presentation/pages/muscle_overview_page.dart';
import '../../features/data_transfer/presentation/pages/data_transfer_page.dart';
import '../../features/admin/presentation/pages/invites_page.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/gym/presentation/pages/gym_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/students/presentation/pages/student_add_page.dart';
import '../../features/students/presentation/pages/students_page.dart';
import 'app_destinations.dart';

part 'app_router.g.dart';

final _key = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    navigatorKey: _key,
    initialLocation: '/login',
    refreshListenable: ValueNotifier(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isOnboardingPage = state.uri.toString() == '/onboarding';

      if (authState.isLoading || onboardingState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn) {
        final isOnboardingComplete = onboardingState.value ?? false;

        if (!isOnboardingComplete) {
          if (!isOnboardingPage) return '/onboarding';
          return null;
        }

        final home = homePathFor(UserRole.fromApi(authState.value?.role));
        if (isOnboardingPage || isLoggingIn) return home;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const WorkoutHistoryPage(),
      ),
      GoRoute(
        path: '/progress/muscles',
        builder: (context, state) => const MuscleOverviewPage(),
      ),
      GoRoute(
        path: '/data',
        builder: (context, state) => const DataTransferPage(),
      ),
      GoRoute(
        path: '/admin/invites',
        builder: (context, state) => const InvitesPage(),
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
          return ExerciseDetailsPage(exercise: exercise);
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
          // Branch 2: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),

          // Branch 3: Analytics (Progress)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 5: Students (personal trainers)
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
          // Branch 6: Gym management (owners)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gym',
                builder: (context, state) => const GymPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
