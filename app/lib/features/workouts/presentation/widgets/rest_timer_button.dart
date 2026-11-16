import 'package:flutter/material.dart';

import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pressable.dart';

class RestTimerButton extends StatelessWidget {
  const RestTimerButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? PulseColors.ink : PulseColors.chalk;
    return Semantics(
      button: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: primary ? PulseColors.volt : PulseColors.graphite,
            borderRadius: BorderRadius.circular(PulseRadii.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
