import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/workout_series_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/entities/set_log_entity.dart';
import '../providers/workout_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/workout_timer.dart';
import '../widgets/timer_notifier.dart';
import '../widgets/number_input_control.dart';
import '../widgets/one_rep_max_display.dart';
import '../widgets/plate_calculator_dialog.dart';
import '../widgets/rpe_info_dialog.dart';
import '../../domain/entities/session_log_entity.dart';
import 'workout_summary_page.dart';
import '../widgets/progress_chart.dart';

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
            } else {
              stopRestTimer();
              // Optional: Play sound or vibrate
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
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Séries', style: Theme.of(context).textTheme.titleLarge),
                        if (warmupSets.value.isEmpty && (workout.series.firstOrNull?.weight ?? 0) > 0)
                          TextButton.icon(
                            onPressed: generateWarmup,
                            icon: const Icon(Icons.fitness_center_outlined, size: 16),
                            label: const Text('Gerar Aquecimento'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (warmupSets.value.isNotEmpty) ...[
                      _buildWarmupList(context, warmupSets),
                      const SizedBox(height: 16),
                    ],
                    _buildSetsList(context, logs, historyLogsAsync.asData?.value.firstOrNull),
                    const SizedBox(height: 24),
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
                            ? () => onFinished(logs.value, notesController.text)
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
              _HistoryView(exerciseId: workout.exerciseId),
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

  Widget _buildExpandableSection(BuildContext context, String title, List<String> items, IconData icon, Color iconColor) {
    return Card(
      child: ExpansionTile(
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


  Widget _buildWarmupList(BuildContext context, ValueNotifier<List<Map<String, dynamic>>> warmupSetsNotifier) {
    final sets = warmupSetsNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aquecimento Sugerido',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sets.asMap().entries.map((e) {
            final index = e.key;
            final set = e.value;
            final isCompleted = set['completed'] as bool;

            return FilterChip(
              label: Text(
                '${set['reps']} reps @ ${set['weight']} kg',
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.orange,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isCompleted,
              onSelected: (selected) {
                final newSets = List<Map<String, dynamic>>.from(sets);
                newSets[index] = {...set, 'completed': selected};
                warmupSetsNotifier.value = newSets;
              },
              checkmarkColor: Colors.white,
              selectedColor: Colors.orange,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              side: BorderSide(
                color: isCompleted ? Colors.transparent : Colors.orange.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
        ),
      ],
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

        return _SetRow(
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

class _HistoryView extends HookConsumerWidget {
  const _HistoryView({required this.exerciseId});
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exerciseId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('Nenhum histórico encontrado'));
        }
        return Column(
          children: [
            if (logs.length >= 2)
              SizedBox(
                height: 200,
                child: ProgressChart(logs: logs),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 100, top: 16),
                itemCount: logs.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(DateFormat('dd/MM/yyyy HH:mm').format(log.date)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...log.sets.asMap().entries.map((e) => Text(
                          'Série ${e.key + 1}: ${e.value.reps} reps @ ${e.value.weight}kg (RPE: ${e.value.rpe ?? "-"})',
                        )),
                        if (log.notes != null && log.notes!.isNotEmpty)
                           Text('Notas: ${log.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar histórico: $e')),
    );
  }
}

class _SetRow extends HookWidget {
  const _SetRow({
    required this.index,
    required this.series,
    required this.log,
    required this.onChanged,
    required this.onCompleted,
    this.lastSet,
  });

  final int index;
  final WorkoutSeriesEntity series;
  final SetLogState log;
  final SetLogEntity? lastSet;
  final ValueChanged<SetLogState> onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: log.isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: log.isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: log.isCompleted
                    ? Colors.green
                    : Colors.grey.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                radius: 12,
                child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meta: ${series.repetitions} reps • ${series.weight} kg',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (lastSet != null)
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        Icons.copy_all,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        'Último: ${lastSet!.reps}x ${lastSet!.weight}kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      tooltip: 'Copiar do histórico',
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      onPressed: !log.isCompleted
                          ? () {
                              onChanged(SetLogState(
                                actualReps: lastSet!.reps,
                                actualWeight: lastSet!.weight,
                                rpe: log.rpe,
                                isCompleted: log.isCompleted,
                              ));
                            }
                          : null,
                    ),
                ],
              ),
              const Spacer(),
              OneRepMaxDisplay(weight: log.actualWeight, reps: log.actualReps),
              if (log.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle, color: Colors.green),
                )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: NumberInputControl(
                  label: 'Reps',
                  value: log.actualReps,
                  enabled: !log.isCompleted,
                  onChanged: (val) {
                    onChanged(SetLogState(
                      actualReps: val,
                      actualWeight: log.actualWeight,
                      rpe: log.rpe,
                      isCompleted: log.isCompleted,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumberInputControl(
                  label: 'Carga (kg)',
                  value: log.actualWeight,
                  enabled: !log.isCompleted,
                  step: 1, // Maybe 1 is better than 2.5 for quick adjustments
                  onChanged: (val) {
                    onChanged(SetLogState(
                      actualReps: log.actualReps,
                      actualWeight: val,
                      rpe: log.rpe,
                      isCompleted: log.isCompleted,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.calculate_outlined),
                tooltip: 'Calculadora de Anilhas',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PlateCalculatorDialog(
                      targetWeight: log.actualWeight.toDouble(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
           Row(
            children: [
              Row(
                children: [
                  const Text('RPE'),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const RpeInfoDialog(),
                      );
                    },
                  ),
                  const Text(': '),
                ],
              ),
              Expanded(
                child: Slider(
                  value: (log.rpe ?? 5).toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: log.rpe?.toString() ?? '-',
                  onChanged: log.isCompleted ? null : (v) {
                    onChanged(SetLogState(
                      actualReps: log.actualReps,
                      actualWeight: log.actualWeight,
                      rpe: v.round(),
                      isCompleted: log.isCompleted,
                    ));
                  },
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  log.rpe?.toString() ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCompleted,
              style: TextButton.styleFrom(
                backgroundColor: log.isCompleted ? Colors.transparent : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: Text(log.isCompleted ? 'Desmarcar' : 'Concluir Série'),
            ),
          ),
        ],
      ),
    );
  }
}
