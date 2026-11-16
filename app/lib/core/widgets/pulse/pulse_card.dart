import 'package:flutter/material.dart';

import '../../theme/pulse_tokens.dart';
import 'pressable.dart';

/// Superfície base do PULSE: cartão arredondado com borda sutil.
class PulseCard extends StatelessWidget {
  const PulseCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.radius = PulseRadii.lg,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? scheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return box;
    return Pressable(onTap: onTap, child: box);
  }
}

/// Rótulo de seção em caixa alta, espaçado.
class PulseSectionLabel extends StatelessWidget {
  const PulseSectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
