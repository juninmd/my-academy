import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NumberInputControl extends HookWidget {
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

  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final Widget? labelSuffix;
  final bool enabled;
  final int min;
  final int max;
  final int step;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value.toString());
    final focusNode = useFocusNode();

    useEffect(() {
      if (int.tryParse(controller.text) != value) {
        controller.text = value.toString();
      }
      return null;
    }, [value]);

    void updateValue(int newValue) {
      if (newValue >= min && newValue <= max) {
        onChanged(newValue);
        controller.text = newValue.toString();
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
            if (labelSuffix != null) labelSuffix!,
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? null : Theme.of(context).disabledColor.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              _ControlButton(
                icon: Icons.remove,
                onPressed: enabled ? () => updateValue(value - step) : null,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  enabled: enabled,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    final val = int.tryParse(v);
                    if (val != null) {
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
              const VerticalDivider(width: 1),
              _ControlButton(
                icon: Icons.add,
                onPressed: enabled ? () => updateValue(value + step) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Center(
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
