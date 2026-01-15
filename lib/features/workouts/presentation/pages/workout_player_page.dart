import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/workout_series_entity.dart';
import 'workout_details_page.dart';
import '../widgets/rest_timer_widget.dart';

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
          isExerciseTimerRunning.value = true;
          exerciseTimer.value = Timer.periodic(const Duration(seconds: 1), (t) {
            exerciseTimerValue.value++;
          });
        }

        void stopExerciseTimer() {
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

        void onExerciseFinished(Map<int, SetLog> logs, String notes) {
          stopRestTimer();
          final currentWorkout = activeWorkouts[currentExerciseIndex.value];
          final newSessionLogs =
              Map<int, ExerciseSessionLog>.from(sessionLogs.value);
          newSessionLogs[currentExerciseIndex.value] = ExerciseSessionLog(
            exerciseId: currentWorkout.exerciseId,
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Treino Concluído!'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Resumo do treino:'),
                      const SizedBox(height: 8),
                      ...newSessionLogs.values.map((log) {
                        final workout = activeWorkouts.firstWhere(
                          (w) => w.exerciseId == log.exerciseId,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '• ${workout.exercise?.name}: ${log.setLogs.length} séries',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            centerTitle: true,
            automaticallyImplyLeading: false,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('groupId', groupId));
  }
}

class _ExercisePlayerView extends HookWidget {
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
  final Function(Map<int, SetLog>, String) onFinished;
  final Function(int) onSetCompleted;

  @override
  Widget build(BuildContext context) {
    final logs = useState<Map<int, SetLog>>(
      Map.fromEntries(
        workout.series.asMap().entries.map(
              (e) => MapEntry(
                e.key,
                SetLog(
                  actualReps: e.value.repetitions,
                  actualWeight: e.value.weight,
                ),
              ),
            ),
      ),
    );
    final notesController = useTextEditingController();

    final allSetsCompleted = workout.series.isEmpty ||
        (logs.value.values.every((l) => l.isCompleted) &&
            logs.value.isNotEmpty &&
            logs.value.length == workout.series.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 100,
      ), // Padding for bottom timer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderImage(context),
          const SizedBox(height: 24),
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
          if (workout.exercise?.mistakes.isNotEmpty == true) ...[
            _buildExpandableSection(
              context,
              'Erros Comuns',
              workout.exercise!.mistakes,
              Icons.warning_amber_rounded,
              Colors.redAccent,
            ),
            const SizedBox(height: 16),
          ],

          Text('Séries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildSetsList(context, logs),
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
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (workout.exercise?.image != null)
              Image.network(
                workout.exercise!.image!,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
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
              ? Colors.redAccent.withOpacity(0.1)
              : Colors.greenAccent.withOpacity(0.1),
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


  Widget _buildSetsList(
    BuildContext context,
    ValueNotifier<Map<int, SetLog>> logs,
  ) {
    return Column(
      children: workout.series.asMap().entries.map((entry) {
        final index = entry.key;
        final series = entry.value;
        final log = logs.value[index];

        if (log == null) return const SizedBox.shrink();

        return _SetRow(
          index: index,
          series: series,
          log: log,
          onChanged: (newLog) {
            final newLogs = Map<int, SetLog>.from(logs.value);
            newLogs[index] = newLog;
            logs.value = newLogs;
          },
          onCompleted: () {
            final newLogs = Map<int, SetLog>.from(logs.value);
            final wasCompleted = log.isCompleted;
            newLogs[index] = SetLog(
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

  Widget _buildStatBadge(BuildContext context, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextSpan(
              text: ' $unit',
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WorkoutEntity>('workout', workout));
    properties.add(DiagnosticsProperty<bool>('isTimerRunning', isTimerRunning));
    properties.add(StringProperty('timerValue', timerValue));
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onToggleTimer', onToggleTimer),
    );
    properties.add(
      ObjectFlagProperty<Function(Map<int, SetLog>, String)>.has(
        'onFinished',
        onFinished,
      ),
    );
    properties.add(
      ObjectFlagProperty<Function(int)>.has('onSetCompleted', onSetCompleted),
    );
  }
}

class SetLog {
  SetLog({
    required this.actualReps,
    required this.actualWeight,
    this.rpe,
    this.isCompleted = false,
  });

  int actualReps;
  int actualWeight;
  int? rpe;
  bool isCompleted;
}

class ExerciseSessionLog {
  ExerciseSessionLog({
    required this.exerciseId,
    required this.setLogs,
    this.notes,
  });

  final int exerciseId;
  final Map<int, SetLog> setLogs;
  final String? notes;
}

class _SetRow extends HookWidget {
  const _SetRow({
    required this.index,
    required this.series,
    required this.log,
    required this.onChanged,
    required this.onCompleted,
    super.key,
  });

  final int index;
  final WorkoutSeriesEntity series;
  final SetLog log;
  final ValueChanged<SetLog> onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final repsController = useTextEditingController(
      text: log.actualReps.toString(),
    );
    final weightController = useTextEditingController(
      text: log.actualWeight.toString(),
    );

    // Sync controllers with state if state changes externally (optional, but good practice)
    useEffect(() {
      if (int.tryParse(repsController.text) != log.actualReps) {
        repsController.text = log.actualReps.toString();
      }
      if (int.tryParse(weightController.text) != log.actualWeight) {
        weightController.text = log.actualWeight.toString();
      }
      return null;
    }, [log]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: log.isCompleted
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: log.isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: log.isCompleted
                    ? Colors.green
                    : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                radius: 12,
                child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Text(
                'Meta: ${series.repetitions} reps • ${series.weight} kg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (log.isCompleted)
                 const Icon(Icons.check_circle, color: Colors.green)
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  enabled: !log.isCompleted,
                  onChanged: (v) {
                    final val = int.tryParse(v);
                    if (val != null) {
                       onChanged(SetLog(
                        actualReps: val,
                        actualWeight: log.actualWeight,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                      ));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carga (kg)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  enabled: !log.isCompleted,
                  onChanged: (v) {
                    final val = int.tryParse(v);
                    if (val != null) {
                      onChanged(SetLog(
                        actualReps: log.actualReps,
                        actualWeight: val,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                      ));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8),
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.grey),
                   borderRadius: BorderRadius.circular(4),
                 ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: log.rpe,
                    hint: const Text('RPE'),
                    items: List.generate(10, (i) => i + 1)
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: log.isCompleted ? null : (v) {
                       onChanged(SetLog(
                        actualReps: log.actualReps,
                        actualWeight: log.actualWeight,
                        rpe: v,
                        isCompleted: log.isCompleted,
                      ));
                    },
                  ),
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
                backgroundColor: log.isCompleted ? Colors.transparent : Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Text(log.isCompleted ? 'Desmarcar' : 'Concluir Série'),
            ),
          ),
        ],
      ),
    );
  }
}
