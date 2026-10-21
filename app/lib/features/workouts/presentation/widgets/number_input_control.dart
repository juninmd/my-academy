import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'step_button.dart';

class NumberInputControl<T extends num> extends HookWidget {
  const NumberInputControl({
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelSuffix,
    this.enabled = true,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    super.key,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final String label;
  final Widget? labelSuffix;
  final bool enabled;
  final num min;
  final num max;
  final num step;

  bool get _decimal => value is double;

  T _coerce(num n) => (_decimal ? n.toDouble() : n.round()) as T;

  static String format(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  T? _parse(String v) {
    final n = num.tryParse(v.replaceAll(',', '.'));
    return n == null ? null : _coerce(n);
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: format(value));
    final focusNode = useFocusNode();

    useEffect(() {
      if (_parse(controller.text) != value) {
        controller.text = format(value);
      }
      return null;
    }, [value]);

    void updateValue(num raw) {
      final newValue = _coerce(raw);
      if (newValue >= min && newValue <= max) {
        onChanged(newValue);
        controller.text = format(newValue);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            // ignore: use_null_aware_elements
            if (labelSuffix != null) labelSuffix!,
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
            color:
                enabled
                    ? null
                    : Theme.of(context).disabledColor.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              StepButton(
                icon: Icons.remove,
                tooltip: 'Diminuir ',
                onPressed: enabled ? () => updateValue(value - step) : null,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Semantics(
                  label: label,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: _decimal,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    enabled: enabled,
                    inputFormatters: [
                      _decimal
                          ? FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[.,]?\d{0,2}'),
                          )
                          : FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (v) {
                      final val = _parse(v);
                      if (val != null && val >= min && val <= max) {
                        onChanged(val);
                      }
                    },
                    onTap: () {
                      controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.text.length,
                      );
                    },
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              StepButton(
                icon: Icons.add,
                tooltip: 'Aumentar ',
                onPressed: enabled ? () => updateValue(value + step) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
