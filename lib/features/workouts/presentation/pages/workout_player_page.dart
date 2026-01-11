import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/workout_entity.dart';
import 'workout_details_page.dart'; // To access the provider

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
        final isTimerRunning = useState(false);
        final timerValue = useState(0);
        final timer = useRef<Timer?>(null);

        // Filter valid workouts (with exercise)
        final activeWorkouts = useMemoized(
          () => workouts.where((w) => w.exercise != null).toList(),
          [workouts],
        );

        void startTimer() {
          isTimerRunning.value = true;
          timer.value = Timer.periodic(const Duration(seconds: 1), (t) {
            timerValue.value++;
          });
        }

        void stopTimer() {
          isTimerRunning.value = false;
          timer.value?.cancel();
        }

        void resetTimer() {
          stopTimer();
          timerValue.value = 0;
        }

        useEffect(() => stopTimer, []);

        String formatTime(int seconds) {
          final m = (seconds ~/ 60).toString().padLeft(2, '0');
          final s = (seconds % 60).toString().padLeft(2, '0');
          return '$m:$s';
        }

        void nextExercise() {
          if (currentExerciseIndex.value < activeWorkouts.length - 1) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            // Finish Logic
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Treino Concluído!'),
                    content: const Text('Parabéns, você finalizou o treino.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.pop(); // Dialog
                          context.pop(); // Player
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
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (currentExerciseIndex.value + 1) / activeWorkouts.length,
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
                    resetTimer();
                  },
                  itemCount: activeWorkouts.length,
                  itemBuilder:
                      (context, index) => _ExercisePlayerView(
                        workout: activeWorkouts[index],
                        isTimerRunning: isTimerRunning.value,
                        timerValue: formatTime(timerValue.value),
                        onToggleTimer: () {
                          isTimerRunning.value ? stopTimer() : startTimer();
                        },
                        onNext: nextExercise,
                      ),
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
  });
  final WorkoutEntity workout;
  final bool isTimerRunning;
  final String timerValue;
  final VoidCallback onToggleTimer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final completedSets = useState<Set<int>>({});

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
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
                      errorBuilder:
                          (c, e, s) => Container(color: Colors.grey[800]),
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

          const SizedBox(height: 24),

          // Timer
          GestureDetector(
            onTap: onToggleTimer,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color:
                    isTimerRunning
                        ? Colors.redAccent.withOpacity(0.2)
                        : Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isTimerRunning ? Colors.redAccent : Colors.greenAccent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTimerRunning ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color:
                        isTimerRunning ? Colors.redAccent : Colors.greenAccent,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    timerValue,
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('Séries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          if (workout.series.isNotEmpty)
            ...workout.series.asMap().entries.map((entry) {
              final index = entry.key;
              final series = entry.value;
              final isCompleted = completedSets.value.contains(index);

              return Card(
                color:
                    isCompleted
                        ? Colors.green.withValues(alpha: 0.2)
                        : Theme.of(context).cardTheme.color,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${series.repetitions} reps • ${series.weight} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Descanso: ${series.rest}s'),
                  trailing: Checkbox(
                    value: isCompleted,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      final newSet = Set<int>.from(completedSets.value);
                      if (val == true) {
                        newSet.add(index);
                      } else {
                        newSet.remove(index);
                      }
                      completedSets.value = newSet;
                    },
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  completedSets.value.length == workout.series.length
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
  }
}
