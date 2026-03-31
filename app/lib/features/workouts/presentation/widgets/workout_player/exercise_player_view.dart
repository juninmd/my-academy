import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;

import '../../../domain/entities/workout_entity.dart';
import '../../../domain/entities/exercise_log_entity.dart';
import '../../../domain/entities/session_log_entity.dart';
import '../../providers/workout_provider.dart';
import '../../../../../utils/one_rep_max_calculator.dart';
import 'workout_set_row.dart';
import 'workout_warmup_list.dart';
import 'workout_history_view.dart';
import 'sliver_tab_bar_delegate.dart';

class ExercisePlayerView extends HookConsumerWidget {
  const ExercisePlayerView({
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

    // Pre-fill notes from previous session
    useEffect(() {
      if (previousNote != null && notesController.text.isEmpty) {
        notesController.text = previousNote;
      }
      return null;
    }, [previousNote]);

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

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: false,
          snap: false,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (workout.exercise?.image != null)
                  CachedNetworkImage(
                    imageUrl: workout.exercise!.image!,
                    fit: BoxFit.cover,
                    errorWidget: (c, e, s) =>
                        Container(color: Colors.grey[800]),
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
        SliverPersistentHeader(
          delegate: SliverTabBarDelegate(
            TabBar(
              controller: tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).disabledColor,
              tabs: const [
                Tab(text: 'Execução'),
                Tab(text: 'Histórico'),
              ],
            ),
          ),
          pinned: true,
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 100,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if ((workout.description?.isNotEmpty ?? false) ||
                    (workout.exercise?.tips.isNotEmpty ?? false))
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Instruções e Dicas',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        if (workout.description?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(workout.description!),
                          ),
                        if (workout.exercise?.tips.isNotEmpty ?? false)
                          ...workout.exercise!.tips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

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
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${currentVolume.toStringAsFixed(0)} kg',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    if (warmupSets.value.isEmpty &&
                        (workout.series.firstOrNull?.weight ?? 0) > 0)
                      TextButton.icon(
                        onPressed: generateWarmup,
                        icon: const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          'Aquecer',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    const Spacer(),
                    if (historyLogsAsync.value != null &&
                        historyLogsAsync.value!.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          final lastLog = historyLogsAsync.value!.first;
                          final newLogs = Map<int, SetLogState>.from(
                            logs.value,
                          );
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

                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas do exercício',
                    hintText: 'Configurações do banco, pegada, etc.',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: allSetsCompleted
                        ? () {
                            void finishAction() {
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
                            }

                            if (isLast) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Finalizar Treino?'),
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
    final sortedIndices = logs.value.keys.toList()..sort();

    return Column(
      children: [
        ...sortedIndices.map((index) {
          final log = logs.value[index]!;
          final series = index < workout.series.length
              ? workout.series[index]
              : null;
          final lastSet = (lastLog != null && lastLog.sets.length > index)
              ? lastLog.sets[index]
              : null;

          return WorkoutSetRow(
            key: ValueKey('set_row_$index'),
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
                type: log.type,
              );
              logs.value = newLogs;
              if (!wasCompleted && series != null) {
                onSetCompleted(series.rest);
              }
            },
            onDelete: () {
              final currentLogs = Map<int, SetLogState>.from(logs.value);
              currentLogs.remove(index);

              final newLogs = <int, SetLogState>{};
              final keys = currentLogs.keys.toList()..sort();
              for (int i = 0; i < keys.length; i++) {
                newLogs[i] = currentLogs[keys[i]]!;
              }
              logs.value = newLogs;
            },
          );
        }),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () {
              final currentLogs = Map<int, SetLogState>.from(logs.value);
              final nextIndex = currentLogs.isEmpty
                  ? 0
                  : currentLogs.keys.reduce(math.max) + 1;
              final lastLog = nextIndex > 0 ? currentLogs[nextIndex - 1] : null;

              currentLogs[nextIndex] = SetLogState(
                actualReps: lastLog?.actualReps ?? 0,
                actualWeight: lastLog?.actualWeight ?? 0,
                rpe: null,
                isCompleted: false,
              );
              logs.value = currentLogs;
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Adicionar Série'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
