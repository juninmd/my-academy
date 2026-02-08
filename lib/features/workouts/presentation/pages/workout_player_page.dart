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
import 'package:intl/intl.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/entities/set_log_entity.dart';
import '../providers/workout_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/workout_timer.dart';
import '../widgets/timer_notifier.dart';
import '../../domain/entities/session_log_entity.dart';
import 'workout_summary_page.dart';
import '../../../../utils/one_rep_max_calculator.dart';

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

        // Global Workout Timer (Total Duration)
        final timerNotifier = useMemoized(() => TimerNotifier()..start(), []);
        useEffect(() {
          return timerNotifier.dispose;
        }, []);

        // Exercise Timer State
        final isExerciseTimerRunning = useState(false);
        final exerciseTimerValue = useState(0);
        final exerciseTimer = useRef<Timer?>(null);

        // Rest Timer State
        final isRestTimerActive = useState(false);
        final restTimerDuration = useState(0);
        final restTimerRemaining = useState(0);
        final restTimer = useRef<Timer?>(null);

        final activeWorkouts = useMemoized(
          () => workouts.where((w) => w.exercise != null).toList(),
          [workouts],
        );

        // Exercise Timer Logic
        void startExerciseTimer() {
          HapticFeedback.mediumImpact();
          isExerciseTimerRunning.value = true;
          exerciseTimer.value = Timer.periodic(const Duration(seconds: 1), (t) {
            exerciseTimerValue.value++;
          });
        }

        void stopExerciseTimer() {
          HapticFeedback.mediumImpact();
          isExerciseTimerRunning.value = false;
          exerciseTimer.value?.cancel();
        }

        void resetExerciseTimer() {
          stopExerciseTimer();
          exerciseTimerValue.value = 0;
        }

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

          restTimer.value = Timer.periodic(const Duration(seconds: 1), (t) {
            if (restTimerRemaining.value > 0) {
              restTimerRemaining.value--;
              if (restTimerRemaining.value <= 3 && restTimerRemaining.value > 0) {
                HapticFeedback.selectionClick();
              }
            } else {
              stopRestTimer();
              HapticFeedback.heavyImpact();
            }
          });
        }

        useEffect(() {
          return () {
            stopExerciseTimer();
            stopRestTimer();
          };
        }, []);

        String formatTime(int seconds) {
          final m = (seconds ~/ 60).toString().padLeft(2, '0');
          final s = (seconds % 60).toString().padLeft(2, '0');
          return '$m:$s';
        }

        Future<void> onExerciseFinished(Map<int, SetLogState> logs, String notes) async {
          HapticFeedback.heavyImpact();
          stopRestTimer();
          final currentWorkout = activeWorkouts[currentExerciseIndex.value];

          // Save to Repository
          final userId = ref.read(authProvider).value?.id;
          if (userId != null) {
             final logEntity = ExerciseLogEntity(
                userId: userId,
                exerciseId: currentWorkout.exerciseId,
                date: DateTime.now(),
                sets: logs.values.map((l) => SetLogEntity(
                    reps: l.actualReps,
                    weight: l.actualWeight,
                    rpe: l.rpe,
                )).toList(),
                notes: notes,
            );
            await ref.read(workoutRepositoryProvider).saveExerciseLog(logEntity);
            ref.invalidate(exerciseLogsProvider(currentWorkout.exerciseId));
          }


          final newSessionLogs =
              Map<int, ExerciseSessionLog>.from(sessionLogs.value);
          newSessionLogs[currentExerciseIndex.value] = ExerciseSessionLog(
            exerciseId: currentWorkout.exerciseId,
            exerciseName: currentWorkout.exercise?.name,
            setLogs: logs,
            notes: notes,
          );
          sessionLogs.value = newSessionLogs;

          if (currentExerciseIndex.value < activeWorkouts.length - 1) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
             if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WorkoutSummaryPage(
                    duration: Duration(seconds: timerNotifier.value),
                    sessionLogs: newSessionLogs,
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
            leading: Center(
              child: WorkoutTimer(notifier: timerNotifier),
            ),
            actions: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  LinearProgressIndicator(
                    value: (currentExerciseIndex.value + 1) /
                        activeWorkouts.length,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        currentExerciseIndex.value = index;
                        resetExerciseTimer();
                      },
                      itemCount: activeWorkouts.length,
                      itemBuilder: (context, index) => _ExercisePlayerView(
                        key: ValueKey(activeWorkouts[index].id ?? index),
                        workout: activeWorkouts[index],
                        isTimerRunning: isExerciseTimerRunning.value,
                        timerValue: formatTime(exerciseTimerValue.value),
                        onToggleTimer: () {
                          isExerciseTimerRunning.value
                              ? stopExerciseTimer()
                              : startExerciseTimer();
                        },
                        onFinished: onExerciseFinished,
                        onSetCompleted: (restTime) {
                          if (restTime > 0) {
                            startRestTimer(restTime);
                          }
                        },
                      ),
                    ),
                  ),
                ],
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
                    onSkip: stopRestTimer,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }
}

class _ExercisePlayerView extends HookConsumerWidget {
  const _ExercisePlayerView({
    required this.workout,
    required this.isTimerRunning,
    required this.timerValue,
    required this.onToggleTimer,
    required this.onFinished,
    required this.onSetCompleted,
    super.key,
  });
  final WorkoutEntity workout;
  final bool isTimerRunning;
  final String timerValue;
  final VoidCallback onToggleTimer;
  final Function(Map<int, SetLogState>, String) onFinished;
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
    final historyLogsAsync = ref.watch(exerciseLogsProvider(workout.exerciseId));

    final allSetsCompleted = workout.series.isEmpty ||
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
        {'weight': (workingWeight * 0.5).round(), 'reps': 12, 'completed': false},
        {'weight': (workingWeight * 0.75).round(), 'reps': 8, 'completed': false},
      ];
    }

    return Column(
      children: [
        _buildHeaderImage(context),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Execução'),
            Tab(text: 'Histórico'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // Execution View
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildExerciseTimer(context),
                    const SizedBox(height: 24),
                     if (workout.description != null && workout.description!.isNotEmpty) ...[
                      _buildInfoSection(context, 'Instruções', workout.description!),
                      const SizedBox(height: 16),
                    ],
                    if (workout.exercise?.tips.isNotEmpty == true) ...[
                      _buildExpandableSection(
                        context,
                        'Dicas',
                        workout.exercise!.tips,
                        Icons.lightbulb_outline,
                        Colors.amber,
                        initiallyExpanded: historyLogsAsync.asData?.value.isEmpty ?? false,
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Séries', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Vol: ${currentVolume.toStringAsFixed(0)}kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (warmupSets.value.isEmpty && (workout.series.firstOrNull?.weight ?? 0) > 0)
                          ActionChip(
                            avatar: const Icon(Icons.fitness_center, size: 16, color: Colors.orange),
                            label: const Text('Aquecer'),
                            onPressed: generateWarmup,
                            backgroundColor: Colors.orange.withValues(alpha: 0.1),
                            side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (warmupSets.value.isNotEmpty) ...[
                      WorkoutWarmupList(warmupSetsNotifier: warmupSets),
                      const SizedBox(height: 16),
                    ],
                    _buildSetsList(context, logs, historyLogsAsync.asData?.value.firstOrNull),
                    const SizedBox(height: 24),
                    if (historyLogsAsync.asData?.value != null)
                      Builder(
                        builder: (context) {
                          final lastNoteLog = historyLogsAsync.asData!.value
                              .where((l) => l.notes != null && l.notes!.isNotEmpty)
                              .firstOrNull;

                          if (lastNoteLog == null) return const SizedBox.shrink();

                          return Container(
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Nota Anterior (${DateFormat('dd/MM').format(lastNoteLog.date)})',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(lastNoteLog.notes!),
                              ],
                            ),
                          );
                        },
                      ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas do exercício',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: senti desconforto no ombro...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: allSetsCompleted
                            ? () {
                                // PR Check
                                final historyLogs = historyLogsAsync.asData?.value ?? [];
                                if (historyLogs.isNotEmpty) {
                                  double currentMax1RM = 0;
                                  for (final log in logs.value.values) {
                                    final oneRM = OneRepMaxCalculator.calculateEpley(
                                        log.actualWeight.toDouble(), log.actualReps);
                                    if (oneRM > currentMax1RM) currentMax1RM = oneRM;
                                  }

                                  double historyMax1RM = 0;
                                  for (final log in historyLogs) {
                                    for (final set in log.sets) {
                                      final oneRM = OneRepMaxCalculator.calculateEpley(
                                          set.weight.toDouble(), set.reps);
                                      if (oneRM > historyMax1RM) historyMax1RM = oneRM;
                                    }
                                  }

                                  if (currentMax1RM > historyMax1RM && historyMax1RM > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.emoji_events, color: Colors.white),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Novo Recorde Pessoal!',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text('1RM estimado: ${currentMax1RM.toStringAsFixed(1)} kg'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.orange,
                                        duration: const Duration(seconds: 4),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                                onFinished(logs.value, notesController.text);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Próximo Exercício',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // History View
              WorkoutHistoryView(exerciseId: workout.exerciseId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
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
    );
  }

  Widget _buildExerciseTimer(BuildContext context) {
    return GestureDetector(
      onTap: onToggleTimer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isTimerRunning
              ? Colors.redAccent.withValues(alpha: 0.1)
              : Colors.greenAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTimerRunning ? Colors.redAccent : Colors.greenAccent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTimerRunning ? Icons.pause : Icons.play_arrow,
              size: 32,
              color: isTimerRunning ? Colors.redAccent : Colors.greenAccent,
            ),
            const SizedBox(width: 16),
            Text(
              timerValue,
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title, List<String> items, IconData icon, Color iconColor, {bool initiallyExpanded = false}) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.map((item) => ListTile(
          dense: true,
          leading: const Icon(Icons.circle, size: 8),
          title: Text(item),
        )).toList(),
      ),
    );
  }


  Widget _buildSetsList(
    BuildContext context,
    ValueNotifier<Map<int, SetLogState>> logs,
    ExerciseLogEntity? lastLog,
  ) {
    return Column(
      children: workout.series.asMap().entries.map((entry) {
        final index = entry.key;
        final series = entry.value;
        final log = logs.value[index];

        // Try to match with last session set
        final lastSet = (lastLog != null && lastLog.sets.length > index)
            ? lastLog.sets[index]
            : null;

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

