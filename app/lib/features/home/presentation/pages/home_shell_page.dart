import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_destinations.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _railBreakpoint = 840.0;
const _extendedRailBreakpoint = 1200.0;

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = UserRole.fromApi(
      ref.watch(authNotifierProvider.select((s) => s.value?.role)),
    );
    final destinations = destinationsFor(role);
    final selected = destinations
        .indexWhere((d) => d.branch == navigationShell.currentIndex)
        .clamp(0, destinations.length - 1);

    void onSelect(int index) {
      final branch = destinations[index].branch;
      navigationShell.goBranch(
        branch,
        initialLocation: branch == navigationShell.currentIndex,
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    if (width < _railBreakpoint) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: onSelect,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    final extended = width >= _extendedRailBreakpoint;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            selectedIndex: selected,
            onDestinationSelected: onSelect,
            labelType:
                extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (extended) ...[
                    const SizedBox(width: 12),
                    Text(
                      'MyAcademy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
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
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
