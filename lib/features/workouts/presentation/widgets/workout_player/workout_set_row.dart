import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../domain/entities/workout_series_entity.dart';
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
    this.onDelete,
    super.key,
  });

  final int index;
  final WorkoutSeriesEntity? series;
  final SetLogState log;
  final SetLogEntity? lastSet;
  final ValueChanged<SetLogState> onChanged;
  final VoidCallback onCompleted;
  final VoidCallback? onDelete;

  Color _getBackgroundColor(BuildContext context) {
    if (log.isCompleted) return Colors.green.withValues(alpha: 0.1);

    switch (log.type) {
      case SetType.warmup:
        return Colors.orange.withValues(alpha: 0.1);
      case SetType.dropset:
        return Colors.purple.withValues(alpha: 0.1);
      case SetType.failure:
        return Colors.red.withValues(alpha: 0.1);
      case SetType.normal:
        return Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (log.isCompleted) return Colors.green.withValues(alpha: 0.5);

    switch (log.type) {
      case SetType.warmup:
        return Colors.orange.withValues(alpha: 0.3);
      case SetType.dropset:
        return Colors.purple.withValues(alpha: 0.3);
      case SetType.failure:
        return Colors.red.withValues(alpha: 0.3);
      case SetType.normal:
        return Theme.of(context).dividerColor.withValues(alpha: 0.1);
    }
  }

  String _getSetTypeLabel(SetType type) {
    switch (type) {
      case SetType.warmup: return 'AQUECIMENTO';
      case SetType.dropset: return 'DROP SET';
      case SetType.failure: return 'FALHA';
      case SetType.normal: return 'NORMAL';
    }
  }

  Color _getSetTypeColor(SetType type, BuildContext context) {
    switch (type) {
      case SetType.warmup: return Colors.orange;
      case SetType.dropset: return Colors.purple;
      case SetType.failure: return Theme.of(context).colorScheme.error;
      case SetType.normal: return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repsLabel = 'Reps';
    final weightLabel = 'kg';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Column(
        children: [
          // Header: Set Info & Type Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const SizedBox(width: 8),
                  PopupMenuButton<SetType>(
                    initialValue: log.type,
                    onSelected: (SetType item) {
                      onChanged(SetLogState(
                        actualReps: log.actualReps,
                        actualWeight: log.actualWeight,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                        type: item,
                      ));
                    },
                    tooltip: 'Alterar tipo de série',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSetTypeColor(log.type, context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getSetTypeColor(log.type, context).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getSetTypeLabel(log.type),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getSetTypeColor(log.type, context),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 14,
                            color: _getSetTypeColor(log.type, context),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<SetType>>[
                      const PopupMenuItem<SetType>(
                        value: SetType.normal,
                        child: Text('Normal'),
                      ),
                      PopupMenuItem<SetType>(
                        value: SetType.warmup,
                        child: Text('Aquecimento', style: TextStyle(color: _getSetTypeColor(SetType.warmup, context))),
                      ),
                      PopupMenuItem<SetType>(
                        value: SetType.dropset,
                        child: Text('Drop Set', style: TextStyle(color: _getSetTypeColor(SetType.dropset, context))),
                      ),
                      PopupMenuItem<SetType>(
                        value: SetType.failure,
                        child: Text('Falha', style: TextStyle(color: _getSetTypeColor(SetType.failure, context))),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lastSet != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap:
                            !log.isCompleted
                                ? () {
                                  onChanged(
                                    SetLogState(
                                      actualReps: lastSet!.reps,
                                      actualWeight: lastSet!.weight,
                                      rpe: log.rpe,
                                      isCompleted: log.isCompleted,
                                      type: log.type,
                                    ),
                                  );
                                }
                                : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
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
                                'Copiar',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          if (lastSet != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Row(
                children: [
                   Icon(Icons.history, size: 12, color: Theme.of(context).disabledColor),
                   const SizedBox(width: 4),
                   Text(
                     'Último: ${lastSet!.weight}kg x ${lastSet!.reps}${lastSet!.rpe != null ? " @ RPE ${lastSet!.rpe}" : ""}',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: Theme.of(context).disabledColor,
                       fontStyle: FontStyle.italic,
                     ),
                   ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Main Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Reps Input
              Expanded(
                flex: 2,
                child: NumberInputControl(
                  label: repsLabel,
                  value: log.actualReps,
                  enabled: !log.isCompleted,
                  onChanged: (val) {
                    onChanged(
                      SetLogState(
                        actualReps: val,
                        actualWeight: log.actualWeight,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                        type: log.type,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Weight Input
              Expanded(
                flex: 2,
                child: NumberInputControl(
                  label: weightLabel,
                  value: log.actualWeight,
                  enabled: !log.isCompleted,
                  step: 1,
                  onChanged: (val) {
                    onChanged(
                      SetLogState(
                        actualReps: log.actualReps,
                        actualWeight: val,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                        type: log.type,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),

              // Plate Calculator Button
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: const Icon(Icons.calculate_outlined, size: 20),
                  tooltip: 'Calculadora de Anilhas',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder:
                          (context) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: PlateCalculatorContent(
                              targetWeight: log.actualWeight.toDouble(),
                            ),
                          ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 4),

              // RPE Selector
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                ), // Align with input fields
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        log.isCompleted
                            ? null
                            : () {
                              showModalBottomSheet(
                                context: context,
                                builder:
                                    (context) => RpeSelectorSheet(
                                      onSelected: (rpe) {
                                        onChanged(
                                          SetLogState(
                                            actualReps: log.actualReps,
                                            actualWeight: log.actualWeight,
                                            rpe: rpe,
                                            isCompleted: log.isCompleted,
                                            type: log.type,
                                          ),
                                        );
                                      },
                                    ),
                              );
                            },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 48, // Match height of NumberInputControl roughly
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            log.rpe != null
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                                : Theme.of(
                                  context,
                                ).disabledColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              log.rpe != null
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3)
                                  : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'RPE',
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.rpe?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  log.rpe != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                    color:
                        log.isCompleted
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
