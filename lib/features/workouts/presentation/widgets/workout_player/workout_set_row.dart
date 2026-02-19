import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../domain/entities/workout_series_entity.dart';
import '../../../domain/entities/set_log_entity.dart';
import '../../../domain/entities/session_log_entity.dart';
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            log.isCompleted
                ? Colors.green.withValues(alpha: 0.05)
                : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              log.isCompleted
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
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              if (lastSet != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap:
                        !log.isCompleted
                            ? () {
                              onChanged(
                                SetLogState(
                                  actualReps: lastSet!.reps,
                                  actualWeight: lastSet!.weight,
                                  rpe: log.rpe,
                                  isCompleted: log.isCompleted,
                                ),
                              );
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 14,
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
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Reps Input
              Expanded(
                flex: 3,
                child: _SetInputControl(
                  label: 'REPS',
                  value: log.actualReps,
                  enabled: !log.isCompleted,
                  onChanged: (val) {
                    onChanged(
                      SetLogState(
                        actualReps: val,
                        actualWeight: log.actualWeight,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Weight Input
              Expanded(
                flex: 4,
                child: _SetInputControl(
                  label: 'KG',
                  value: log.actualWeight,
                  enabled: !log.isCompleted,
                  onChanged: (val) {
                    onChanged(
                      SetLogState(
                        actualReps: log.actualReps,
                        actualWeight: val,
                        rpe: log.rpe,
                        isCompleted: log.isCompleted,
                      ),
                    );
                  },
                  suffix: IconButton(
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
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
              ),
              const SizedBox(width: 12),

              // RPE Selector (Pill)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
                                        ),
                                      );
                                    },
                                  ),
                            );
                          },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          log.rpe != null
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
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
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
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

              const SizedBox(width: 12),

              // Completion Button
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: onCompleted,
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          log.isCompleted
                              ? Colors.green
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 28,
                      color:
                          log.isCompleted
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class _SetInputControl extends HookWidget {
  const _SetInputControl({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.suffix,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value.toString());
    final focusNode = useFocusNode();

    // Update text when value changes externally
    useEffect(() {
      if (int.tryParse(controller.text) != value) {
        controller.text = value.toString();
        // Keep cursor at end if focused
        if (focusNode.hasFocus) {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      }
      return null;
    }, [value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color:
                enabled
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).disabledColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              _ControlButton(
                icon: Icons.remove,
                onPressed: enabled ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  enabled: enabled,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final val = int.tryParse(v);
                    if (val != null) {
                      onChanged(val);
                    }
                  },
                  onTap: () {
                    if (controller.text == '0') {
                      controller.clear();
                    }
                  },
                ),
              ),
              _ControlButton(
                icon: Icons.add,
                onPressed: enabled ? () => onChanged(value + 1) : null,
              ),
              if (suffix != null) ...[
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
                suffix!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color:
                onPressed != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
