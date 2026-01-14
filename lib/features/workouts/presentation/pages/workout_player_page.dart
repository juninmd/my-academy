import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
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

        void nextExercise() {
          stopRestTimer();
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
                content: const Text('Parabéns, você finalizou o treino.'),
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
                        workout: activeWorkouts[index],
                        isTimerRunning: isExerciseTimerRunning.value,
                        timerValue: formatTime(exerciseTimerValue.value),
                        onToggleTimer: () {
                          isExerciseTimerRunning.value
                              ? stopExerciseTimer()
                              : startExerciseTimer();
                        },
                        onNext: nextExercise,
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
    required this.onNext,
    required this.onSetCompleted,
  });
  final WorkoutEntity workout;
  final bool isTimerRunning;
  final String timerValue;
  final VoidCallback onToggleTimer;
  final VoidCallback onNext;
  final Function(int) onSetCompleted;

  @override
  Widget build(BuildContext context) {
    final completedSets = useState<Set<int>>({});

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
             _buildExpandableSection(context, 'Dicas', workout.exercise!.tips, Icons.lightbulb_outline, Colors.amber),
             const SizedBox(height: 16),
          ],
           if (workout.exercise?.mistakes.isNotEmpty == true) ...[
             _buildExpandableSection(context, 'Erros Comuns', workout.exercise!.mistakes, Icons.warning_amber_rounded, Colors.redAccent),
             const SizedBox(height: 16),
          ],

          Text('Séries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildSetsList(context, completedSets),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: completedSets.value.length == workout.series.length
                  ? onNext
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
      BuildContext context, ValueNotifier<Set<int>> completedSets) {
    return Column(
      children: workout.series.asMap().entries.map((entry) {
        final index = entry.key;
        final series = entry.value;
        final isCompleted = completedSets.value.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
             color: isCompleted
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent,
            )
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
              foregroundColor: isCompleted ? Colors.white : Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Row(
              children: [
                _buildStatBadge(context, '${series.repetitions}', 'reps'),
                const SizedBox(width: 12),
                _buildStatBadge(context, '${series.weight}', 'kg'),
              ],
            ),
            trailing: InkWell(
              onTap: () {
                final newSet = Set<int>.from(completedSets.value);
                if (!isCompleted) {
                  newSet.add(index);
                  onSetCompleted(series.rest);
                } else {
                  newSet.remove(index);
                }
                completedSets.value = newSet;
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Theme.of(context).disabledColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Feito' : 'Concluir',
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
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
    properties.add(ObjectFlagProperty<VoidCallback>.has('onNext', onNext));
    properties.add(ObjectFlagProperty<Function(int)>.has('onSetCompleted', onSetCompleted));
  }
}
