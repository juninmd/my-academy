import 'package:flutter/material.dart';

import '../../../../core/router/app_destinations.dart';
import 'pulse_nav_bar.dart';

/// Trilho lateral para tablets e desktop, com o botão Pulse no topo.
class PulseRail extends StatelessWidget {
  const PulseRail({
    required this.destinations,
    required this.extended,
    required this.selectedIndex,
    required this.onSelect,
    required this.onPulse,
    super.key,
  });

  final List<AppDestination> destinations;
  final bool extended;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onPulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: extended
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (extended) ...[
                  const SizedBox(width: 10),
                  Text('MY ACADEMY', style: theme.textTheme.titleMedium),
                ],
              ],
            ),
            const SizedBox(height: 20),
            PulseButton(onTap: onPulse),
          ],
        ),
      ),
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    );
  }
}
