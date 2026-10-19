import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/workout_provider.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/workout_timer.dart';
import '../widgets/timer_notifier.dart';
import '../../domain/entities/session_log_entity.dart';
import 'workout_summary_page.dart';
import '../widgets/plate_calculator_dialog.dart';
import '../widgets/one_rep_max_calculator_dialog.dart';
import '../../../home/presentation/widgets/quick_timer_dialog.dart';
import '../widgets/workout_player/exercise_player_view.dart';
import '../hooks/use_rest_timer.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../profile/presentation/providers/settings_provider.dart';
import '../widgets/workout_player/exit_confirmation_dialog.dart';

class WorkoutPlayerPage extends HookConsumerWidget {
  const WorkoutPlayerPage({required this.groupId, super.key});
  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(workoutGroupByIdProvider(groupId));

    return groupAsync.when(
      data: (group) {
        if (group == null || group.workouts.isEmpty) {
          return const Scaffold(body: Center(child: Text('Treino inválido')));
        }

        final workouts = group.workouts;
        final pageController = usePageController();
        final currentExerciseIndex = useState(0);
        final sessionLogs = useState<Map<int, ExerciseSessionLog>>({});
        final newRecords = useState<List<String>>([]);

        // Global Workout Timer (Total Duration)
        final timerNotifier = useMemoized(() => TimerNotifier()..start(), []);
        useEffect(() {
          return timerNotifier.dispose;
        }, []);

        final restAlert = ref.watch(
          settingsProvider.select((s) => s.restAlertEnabled),
        );
        final restTimer = useRestTimer(
          notifications:
              restAlert ? ref.read(notificationServiceProvider) : null,
        );

        final activeWorkouts = useMemoized(
          () => workouts.where((w) => w.exercise != null).toList(),
          [workouts],
        );

        Future<void> onExerciseFinished(
          Map<int, SetLogState> logs,
          String notes,
          String? recordBroken,
        ) async {
          await HapticFeedback.heavyImpact();
          restTimer.stop();

          if (recordBroken != null) {
            newRecords.value = [...newRecords.value, recordBroken];
          }

          final currentWorkout = activeWorkouts[currentExerciseIndex.value];

          final newSessionLogs = Map<int, ExerciseSessionLog>.from(
            sessionLogs.value,
          );
          newSessionLogs[currentExerciseIndex.value] = ExerciseSessionLog(
            exerciseId: currentWorkout.exerciseId,
            exerciseName: currentWorkout.exercise?.name,
            setLogs: logs,
            notes: notes,
          );
          sessionLogs.value = newSessionLogs;

          if (currentExerciseIndex.value < activeWorkouts.length - 1) {
            await pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            if (context.mounted) {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => WorkoutSummaryPage(
                        groupId: groupId,
                        duration: Duration(seconds: timerNotifier.value),
                        sessionLogs: newSessionLogs,
                        newRecords: newRecords.value,
                      ),
                ),
              );
            }
          }
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await showExitConfirmationDialog(context);
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(group.name),
              centerTitle: true,
              leading: Center(child: WorkoutTimer(notifier: timerNotifier)),
              elevation: 0,
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value:
                      (currentExerciseIndex.value + 1) / activeWorkouts.length,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.build_circle_outlined),
                  tooltip: 'Ferramentas',
                  onSelected: (value) {
                    if (value == 'plate') {
                      showDialog(
                        context: context,
                        builder:
                            (context) =>
                                const PlateCalculatorDialog(targetWeight: 0),
                      );
                    } else if (value == 'timer') {
                      showDialog(
                        context: context,
                        builder: (context) => const QuickTimerDialog(),
                      );
                    } else if (value == '1rm') {
                      showDialog(
                        context: context,
                        builder: (context) => const OneRepMaxCalculatorDialog(),
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'plate',
                          child: Row(
                            children: [
                              Icon(Icons.calculate_outlined),
                              SizedBox(width: 8),
                              Text('Calculadora de Anilhas'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'timer',
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(width: 8),
                              Text('Cronômetro Rápido'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: '1rm',
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center),
                              SizedBox(width: 8),
                              Text('Calculadora 1RM'),
                            ],
                          ),
                        ),
                      ],
                ),
                IconButton(
                  onPressed: () async {
                    final shouldPop = await showExitConfirmationDialog(context);
                    if (shouldPop && context.mounted) {
                      context.pop();
                    }
                  },
                  tooltip: 'Sair do treino',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    currentExerciseIndex.value = index;
                  },
                  itemCount: activeWorkouts.length,
                  itemBuilder:
                      (context, index) => ExercisePlayerView(
                        key: ValueKey(activeWorkouts[index].id ?? index),
                        workout: activeWorkouts[index],
                        isLast: index == activeWorkouts.length - 1,
                        onFinished: onExerciseFinished,
                        onSetCompleted: (restTime) {
                          if (restTime > 0) {
                            restTimer.start(restTime);
                          }
                        },
                      ),
                ),
                if (restTimer.isActive.value)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RestTimerWidget(
                      remainingSeconds: restTimer.remaining.value,
                      totalSeconds: restTimer.duration.value,
                      onAdd10Seconds: () => restTimer.extend(10),
                      onAdd30Seconds: () => restTimer.extend(30),
                      onSkip: restTimer.stop,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }
}
