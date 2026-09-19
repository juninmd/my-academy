import 'package:flutter/material.dart';

/// +/- button of a numeric stepper, announced by its tooltip.
class StepButton extends StatelessWidget {
  const StepButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 40,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(child: Icon(icon, size: 20)),
        ),
      ),
    );
  }
}
