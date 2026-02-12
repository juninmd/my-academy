import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../domain/entities/workout_series_entity.dart';
import '../../../domain/entities/set_log_entity.dart';
import '../../../domain/entities/session_log_entity.dart';
import '../number_input_control.dart';
import '../plate_calculator_dialog.dart';
import '../rpe_selector_sheet.dart';

class WorkoutSetRow extends HookWidget {
  const WorkoutSetRow({
    required this.index,
    required this.series,
    required this.log,
    required this.onChanged,
    required this.onCompleted,
    this.lastSet,
    super.key,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: log.isCompleted
            ? Colors.green.withValues(alpha: 0.05)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: log.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Header: Set Info & History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SÉRIE ${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              if (lastSet != null)
                GestureDetector(
                  onTap: !log.isCompleted
                      ? () {
                          onChanged(SetLogState(
                            actualReps: lastSet!.reps,
                            actualWeight: lastSet!.weight,
                            rpe: log.rpe,
                            isCompleted: log.isCompleted,
                          ));
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lastSet!.reps}x ${lastSet!.weight}kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Reps Input
              Expanded(
                flex: 2,
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
              const SizedBox(width: 8),
              // Weight Input
              Expanded(
                 flex: 2,
                 child: NumberInputControl(
                  label: 'kg',
                  labelSuffix: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: PlateCalculatorContent(
                              targetWeight: log.actualWeight.toDouble(),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.calculate,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  value: log.actualWeight,
                  enabled: !log.isCompleted,
                  step: 1,
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

              // RPE Selector
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 18), // Align with input center roughly
                  InkWell(
                    onTap: log.isCompleted ? null : () {
                       showModalBottomSheet(
                        context: context,
                        builder: (context) => RpeSelectorSheet(
                          onSelected: (rpe) {
                            onChanged(SetLogState(
                              actualReps: log.actualReps,
                              actualWeight: log.actualWeight,
                              rpe: rpe,
                              isCompleted: log.isCompleted,
                            ));
                          },
                        ),
                       );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'RPE ${log.rpe ?? '-'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Completion Button
              InkWell(
                onTap: onCompleted,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: log.isCompleted
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    color: log.isCompleted ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
