import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final bool value;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child:
            value
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : const Icon(
                  Icons.check_box_outline_blank,
                  size: 16,
                  color: Colors.black,
                ),
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('value', value));
    properties.add(
      ObjectFlagProperty<Function(bool? p1)>.has('onChanged', onChanged),
    );
  }
}
