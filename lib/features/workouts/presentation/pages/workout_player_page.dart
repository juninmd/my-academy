import '../widgets/workout_player/workout_set_row.dart';
import '../widgets/workout_player/workout_history_view.dart';
import '../widgets/workout_player/workout_warmup_list.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../providers/workout_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/workout_timer.dart';
import '../widgets/timer_notifier.dart';
import '../../domain/entities/session_log_entity.dart';
import 'workout_summary_page.dart';
import '../../../../utils/one_rep_max_calculator.dart';
import '../widgets/plate_calculator_dialog.dart';
import '../widgets/one_rep_max_calculator_dialog.dart';
import '../../../home/presentation/widgets/quick_timer_dialog.dart';

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

        // Rest Timer State
        final isRestTimerActive = useState(false);
        final restTimerDuration = useState(0);
        final restTimerRemaining = useState(0);
        final restTimer = useRef<Timer?>(null);

        final activeWorkouts = useMemoized(
          () => workouts.where((w) => w.exercise != null).toList(),
          [workouts],
        );

        // Rest Timer Logic
        void stopRestTimer() {
          isRestTimerActive.value = false;
          restTimer.value?.cancel();
        }

        void startRestTimer(int duration) {
          stopRestTimer();
          restTimerDuration.value = duration;
          restTimerRemaining.value = duration;
          isRestTimerActive.value = true;

          restTimer.value = Timer.periodic(const Duration(seconds: 1), (
            t,
          ) async {
            if (restTimerRemaining.value > 0) {
              restTimerRemaining.value--;
              if (restTimerRemaining.value <= 3 &&
                  restTimerRemaining.value > 0) {
                await HapticFeedback.selectionClick();
              }
            } else {
              stopRestTimer();
              await HapticFeedback.heavyImpact();
            }
          });
        }

        useEffect(() {
          return () {
            stopRestTimer();
          };
        }, []);

        Future<void> onExerciseFinished(
          Map<int, SetLogState> logs,
          String notes,
          String? recordBroken,
        ) async {
          await HapticFeedback.heavyImpact();
          stopRestTimer();

          if (recordBroken != null) {
            newRecords.value = [...newRecords.value, recordBroken];
          }

          final currentWorkout = activeWorkouts[currentExerciseIndex.value];

          // Save to Repository
          final userId = ref.read(authProvider).value?.id;
          if (userId != null) {
            final logEntity = ExerciseLogEntity(
              userId: userId,
              exerciseId: currentWorkout.exerciseId,
              date: DateTime.now(),
              sets:
                  logs.values
                      .map(
                        (l) => SetLogEntity(
                          reps: l.actualReps,
                          weight: l.actualWeight,
                          rpe: l.rpe,
                          type: l.type,
                        ),
                      )
                      .toList(),
              notes: notes,
            );
            await ref
                .read(workoutRepositoryProvider)
                .saveExerciseLog(logEntity);
            ref.invalidate(exerciseLogsProvider(currentWorkout.exerciseId));
          }

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
                        duration: Duration(seconds: timerNotifier.value),
                        sessionLogs: newSessionLogs,
                        newRecords: newRecords.value,
                      ),
                ),
              );
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            centerTitle: true,
            leading: Center(child: WorkoutTimer(notifier: timerNotifier)),
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (currentExerciseIndex.value + 1) / activeWorkouts.length,
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
                onPressed: () => context.pop(),
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
                  // resetExerciseTimer(); // Removed
                },
                itemCount: activeWorkouts.length,
                itemBuilder:
                    (context, index) => _ExercisePlayerView(
                      key: ValueKey(activeWorkouts[index].id ?? index),
                      workout: activeWorkouts[index],
                      isLast: index == activeWorkouts.length - 1,
                      onFinished: onExerciseFinished,
                      onSetCompleted: (restTime) {
                        if (restTime > 0) {
                          startRestTimer(restTime);
                        }
                      },
                    ),
              ),
              if (isRestTimerActive.value)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: RestTimerWidget(
                    remainingSeconds: restTimerRemaining.value,
                    totalSeconds: restTimerDuration.value,
                    onAdd10Seconds: () {
                      restTimerRemaining.value += 10;
                      restTimerDuration.value += 10;
                    },
                    onAdd30Seconds: () {
                      restTimerRemaining.value += 30;
                      restTimerDuration.value += 30;
                    },
                    onSkip: stopRestTimer,
                  ),
                ),
            ],
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

class _ExercisePlayerView extends HookConsumerWidget {
  const _ExercisePlayerView({
    required this.workout,
    required this.isLast,
    required this.onFinished,
    required this.onSetCompleted,
    super.key,
  });
  final WorkoutEntity workout;
  final bool isLast;
  final Function(Map<int, SetLogState>, String, String?) onFinished;
  final Function(int) onSetCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = useState<Map<int, SetLogState>>(
      Map.fromEntries(
        workout.series.asMap().entries.map(
          (e) => MapEntry(
            e.key,
            SetLogState(
              actualReps: e.value.repetitions,
              actualWeight: e.value.weight,
            ),
          ),
        ),
      ),
    );

    // Warm-up sets state (List of pairs: [weight, reps, completed])
    final warmupSets = useState<List<Map<String, dynamic>>>([]);
    final notesController = useTextEditingController();
    final tabController = useTabController(initialLength: 2);
    final historyLogsAsync = ref.watch(
      exerciseLogsProvider(workout.exerciseId),
    );

    final previousNote = useMemoized(() {
      final history = historyLogsAsync.value;
      if (history == null) return null;
      for (final log in history) {
        if (log.notes != null && log.notes!.isNotEmpty) {
          return log.notes;
        }
      }
      return null;
    }, [historyLogsAsync.value]);

    // Smart Pre-fill Logic
    useEffect(() {
      if (historyLogsAsync.asData != null &&
          historyLogsAsync.value != null &&
          historyLogsAsync.value!.isNotEmpty) {
        final lastLog = historyLogsAsync.value!.first;
        bool updated = false;
        final newLogs = Map<int, SetLogState>.from(logs.value);

        for (var entry in newLogs.entries) {
          if (entry.value.actualWeight == 0 &&
              entry.key < lastLog.sets.length) {
            final lastSet = lastLog.sets[entry.key];
            newLogs[entry.key] = SetLogState(
              actualReps: lastSet.reps,
              actualWeight: lastSet.weight,
              rpe: entry.value.rpe,
              isCompleted: false,
            );
            updated = true;
          }
        }

        if (updated) {
          Future.microtask(() {
            logs.value = newLogs;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesos carregados.'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        }
      }
      return null;
    }, [historyLogsAsync.asData?.value]);

    final allSetsCompleted =
        workout.series.isEmpty ||
        (logs.value.values.every((l) => l.isCompleted) &&
            logs.value.isNotEmpty &&
            logs.value.length == workout.series.length);

    // Calculate current session volume
    final currentVolume = logs.value.values
        .where((l) => l.isCompleted)
        .fold(0.0, (sum, l) => sum + (l.actualWeight * l.actualReps));

    void generateWarmup() {
      if (workout.series.isEmpty) return;
      final workingWeight = workout.series.first.weight;
      if (workingWeight == 0) return;

      warmupSets.value = [
        {
          'weight': (workingWeight * 0.5).round(),
          'reps': 12,
          'completed': false,
        },
        {
          'weight': (workingWeight * 0.75).round(),
          'reps': 8,
          'completed': false,
        },
      ];
    }

    // Using NestedScrollView here would be tricky inside a PageView.
    // Instead we use a CustomScrollView with SliverAppBar for the image.
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
           SliverAppBar(
             expandedHeight: 220,
             floating: false,
             pinned: false, // Scroll away
             snap: false,
             automaticallyImplyLeading: false, // No back button
             flexibleSpace: FlexibleSpaceBar(
               background: Stack(
                 fit: StackFit.expand,
                 children: [
                    if (workout.exercise?.image != null)
                      CachedNetworkImage(
                        imageUrl: workout.exercise!.image!,
                        fit: BoxFit.cover,
                        errorWidget: (c, e, s) => Container(color: Colors.grey[800]),
                      )
                    else
                      Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.fitness_center, size: 48),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        workout.exercise?.name ?? 'Exercício',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                    ),
                 ],
               ),
             ),
           ),
           // We can put the TabBar in a SliverPersistentHeader if we want it to pin.
           SliverPersistentHeader(
             delegate: _SliverTabBarDelegate(
               TabBar(
                 controller: tabController,
                 labelColor: Theme.of(context).colorScheme.primary,
                 unselectedLabelColor: Theme.of(context).disabledColor,
                 tabs: const [Tab(text: 'Execução'), Tab(text: 'Histórico')],
               ),
             ),
             pinned: true,
           ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            // Execution Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions (Collapsible)
                  if ((workout.description?.isNotEmpty ?? false) || (workout.exercise?.tips.isNotEmpty ?? false))
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                         title: const Row(children: [
                           Icon(Icons.info_outline, size: 20),
                           SizedBox(width: 8),
                           Text('Instruções e Dicas', style: TextStyle(fontSize: 14)),
                         ]),
                         tilePadding: EdgeInsets.zero,
                         children: [
                           if (workout.description?.isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(workout.description!),
                              ),
                           if (workout.exercise?.tips.isNotEmpty ?? false)
                              ...workout.exercise!.tips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check, size: 14, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodySmall)),
                                  ],
                                ),
                              )),
                         ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Séries',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                         Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.fitness_center, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currentVolume.toStringAsFixed(0)} kg',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                  ),
                  const SizedBox(height: 8),

                  // Warmup & Copy
                  Row(
                    children: [
                       if (warmupSets.value.isEmpty && (workout.series.firstOrNull?.weight ?? 0) > 0)
                          TextButton.icon(
                            onPressed: generateWarmup,
                            icon: const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                            label: const Text('Aquecer', style: TextStyle(color: Colors.orange)),
                          ),
                       const Spacer(),
                       if (historyLogsAsync.value != null && historyLogsAsync.value!.isNotEmpty)
                          TextButton.icon(
                             onPressed: () {
                                    final lastLog = historyLogsAsync.value!.first;
                                    final newLogs = Map<int, SetLogState>.from(logs.value);
                                    bool updated = false;
                                    for (var entry in newLogs.entries) {
                                      if (entry.key < lastLog.sets.length) {
                                        final lastSet = lastLog.sets[entry.key];
                                        if (!entry.value.isCompleted) {
                                          newLogs[entry.key] = SetLogState(
                                            actualReps: lastSet.reps,
                                            actualWeight: lastSet.weight,
                                            rpe: entry.value.rpe,
                                            isCompleted: false,
                                          );
                                          updated = true;
                                        }
                                      }
                                    }
                                    if (updated) {
                                      logs.value = newLogs;
                                    }
                             },
                             icon: const Icon(Icons.copy, size: 16),
                             label: const Text('Copiar Anterior'),
                          ),
                    ],
                  ),

                  if (warmupSets.value.isNotEmpty) ...[
                      WorkoutWarmupList(warmupSetsNotifier: warmupSets),
                      const SizedBox(height: 16),
                    ],

                  _buildSetsList(
                      context,
                      workout,
                      logs,
                      historyLogsAsync.asData?.value.firstOrNull,
                      onSetCompleted,
                  ),

                  const SizedBox(height: 24),

                  if (previousNote != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sticky_note_2,
                                size: 16,
                                color: Colors.amber[800],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Nota Anterior',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            previousNote,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                  // Notes
                  TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas do exercício',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      maxLines: 2,
                  ),

                  const SizedBox(height: 32),

                  // Next Button
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed:
                          allSetsCompleted
                              ? () {
                                final finishAction = () {
                                  // PR Check logic (simplified for brevity but should be same)
                                  final historyLogs =
                                      historyLogsAsync.asData?.value ?? [];
                                  String? recordMessage;
                                  if (historyLogs.isNotEmpty) {
                                    double currentMax1RM = 0;
                                    for (final log in logs.value.values) {
                                      final oneRM =
                                          OneRepMaxCalculator.calculateEpley(
                                            log.actualWeight.toDouble(),
                                            log.actualReps,
                                          );
                                      if (oneRM > currentMax1RM) {
                                        currentMax1RM = oneRM;
                                      }
                                    }
                                    double historyMax1RM = 0;
                                    for (final log in historyLogs) {
                                      for (final set in log.sets) {
                                        final oneRM =
                                            OneRepMaxCalculator.calculateEpley(
                                              set.weight.toDouble(),
                                              set.reps,
                                            );
                                        if (oneRM > historyMax1RM) {
                                          historyMax1RM = oneRM;
                                        }
                                      }
                                    }
                                    if (currentMax1RM > historyMax1RM &&
                                        historyMax1RM > 0) {
                                      recordMessage =
                                          '${workout.exercise?.name}: ${currentMax1RM.toStringAsFixed(1)}kg (1RM)';
                                    }
                                  }
                                  onFinished(
                                    logs.value,
                                    notesController.text,
                                    recordMessage,
                                  );
                                };

                                if (isLast) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            'Finalizar Treino?',
                                          ),
                                          content: const Text(
                                            'Deseja encerrar e salvar o treino agora?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => context.pop(),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                context.pop();
                                                finishAction();
                                              },
                                              child: const Text('Finalizar'),
                                            ),
                                          ],
                                        ),
                                  );
                                } else {
                                  finishAction();
                                }
                              }
                              : null,
                      child: Text(
                        isLast ? 'Finalizar Treino' : 'Próximo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // History Tab (Keep simple)
            Padding(
               padding: const EdgeInsets.only(bottom: 100),
               child: WorkoutHistoryView(exerciseId: workout.exerciseId),
            ),
          ],
        ),
    );
  }

  Widget _buildSetsList(
    BuildContext context,
    WorkoutEntity workout,
    ValueNotifier<Map<int, SetLogState>> logs,
    ExerciseLogEntity? lastLog,
    Function(int) onSetCompleted,
  ) {
    return Column(
      children:
          workout.series.asMap().entries.map((entry) {
            final index = entry.key;
            final series = entry.value;
            final log = logs.value[index];
            final lastSet = (lastLog != null && lastLog.sets.length > index) ? lastLog.sets[index] : null;

            if (log == null) return const SizedBox.shrink();

            return WorkoutSetRow(
              index: index,
              series: series,
              log: log,
              lastSet: lastSet,
              onChanged: (newLog) {
                final newLogs = Map<int, SetLogState>.from(logs.value);
                newLogs[index] = newLog;
                logs.value = newLogs;
              },
              onCompleted: () {
                HapticFeedback.mediumImpact();
                final newLogs = Map<int, SetLogState>.from(logs.value);
                final wasCompleted = log.isCompleted;
                newLogs[index] = SetLogState(
                  actualReps: log.actualReps,
                  actualWeight: log.actualWeight,
                  rpe: log.rpe,
                  isCompleted: !wasCompleted,
                );
                logs.value = newLogs;
                if (!wasCompleted) {
                  onSetCompleted(series.rest);
                }
              },
            );
          }).toList(),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
