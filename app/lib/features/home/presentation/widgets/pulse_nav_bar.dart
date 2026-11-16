import 'package:flutter/material.dart';

import '../../../../core/router/app_destinations.dart';
import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pressable.dart';
import 'pulse_button.dart';

export 'pulse_button.dart';

/// Barra inferior flutuante com o botão Pulse no centro.
class PulseNavBar extends StatelessWidget {
  const PulseNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.onPulse,
    super.key,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onPulse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final half = (destinations.length / 2).ceil();
    Widget tab(int i) => Expanded(
      child: _NavTab(
        destination: destinations[i],
        selected: i == selectedIndex,
        onTap: () => onSelect(i),
      ),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(PulseRadii.xl),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < half; i++) tab(i),
            PulseButton(onTap: onPulse),
            for (var i = half; i < destinations.length; i++) tab(i),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: PulseMotion.press * 2,
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  key: ValueKey(selected),
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
              AnimatedContainer(
                duration: PulseMotion.enter,
                curve: PulseMotion.emphasized,
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: selected ? 16 : 0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão central que abre as ações rápidas.
