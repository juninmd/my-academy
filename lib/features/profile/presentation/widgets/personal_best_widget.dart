import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/one_rep_max_calculator.dart';
import '../../../workouts/domain/entities/exercise_entity.dart';
import '../../../workouts/domain/entities/exercise_log_entity.dart';

class PersonalBestWidget extends StatelessWidget {
  const PersonalBestWidget({
    required this.logs,
    required this.exercises,
    super.key,
  });

  final List<ExerciseLogEntity> logs;
  final List<ExerciseEntity> exercises;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    // 1. Calculate Max 1RM for each exercise
    final prMap = <int, _PREntry>{};

    for (final log in logs) {
      for (final set in log.sets) {
        final oneRM = OneRepMaxCalculator.calculateEpley(
          set.weight.toDouble(),
          set.reps,
        );

        if (!prMap.containsKey(log.exerciseId) ||
            oneRM > prMap[log.exerciseId]!.weight) {
          prMap[log.exerciseId] = _PREntry(
            weight: oneRM,
            date: log.date,
            actualWeight: set.weight.toDouble(),
            actualReps: set.reps,
          );
        }
      }
    }

    // 2. Map to display objects and sort
    final prs =
        prMap.entries.map((e) {
          final exercise = exercises.where((ex) => ex.id == e.key).firstOrNull;
          return _PRDisplay(
            name: exercise?.name ?? 'Exercício ${e.key}',
            oneRM: e.value.weight,
            date: e.value.date,
            details:
                '${e.value.actualWeight.toStringAsFixed(0)}kg x ${e.value.actualReps}',
          );
        }).toList();

    // Sort by 1RM descending
    prs.sort((a, b) => b.oneRM.compareTo(a.oneRM));

    // Take top 5
    final topPRs = prs.take(5).toList();

    if (topPRs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recordes Pessoais (1RM Estimado)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // Fixed height for cards
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topPRs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final pr = topPRs[index];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pr.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                    const Spacer(),
                    Text(
                      '${pr.oneRM.toStringAsFixed(1)} kg',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pr.details,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yy').format(pr.date),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PREntry {
  final double weight;
  final DateTime date;
  final double actualWeight;
  final int actualReps;

  _PREntry({
    required this.weight,
    required this.date,
    required this.actualWeight,
    required this.actualReps,
  });
}

class _PRDisplay {
  final String name;
  final double oneRM;
  final DateTime date;
  final String details;

  _PRDisplay({
    required this.name,
    required this.oneRM,
    required this.date,
    required this.details,
  });
}
