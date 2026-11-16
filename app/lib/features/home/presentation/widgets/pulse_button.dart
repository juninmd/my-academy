import 'package:flutter/material.dart';

import '../../../../core/widgets/pulse/pressable.dart';

class PulseButton extends StatelessWidget {
  const PulseButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Ações rápidas',
      child: Semantics(
        button: true,
        label: 'Ações rápidas',
        child: Pressable(
          onTap: onTap,
          scale: 0.9,
          child: Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(Icons.bolt_rounded, color: scheme.onPrimary, size: 30),
          ),
        ),
      ),
    );
  }
}
