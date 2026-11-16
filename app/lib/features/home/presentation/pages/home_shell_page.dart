import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_destinations.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/pulse_action_sheet.dart';
import '../widgets/pulse_nav_bar.dart';
import '../widgets/pulse_rail.dart';

const _railBreakpoint = 840.0;
const _extendedRailBreakpoint = 1200.0;

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int branch) => navigationShell.goBranch(
    branch,
    initialLocation: branch == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = UserRole.fromApi(
      ref.watch(authNotifierProvider.select((s) => s.value?.role)),
    );
    final current = navigationShell.currentIndex;
    final width = MediaQuery.sizeOf(context).width;

    if (width < _railBreakpoint) {
      final tabs = barDestinationsFor(role);
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: PulseNavBar(
          destinations: tabs,
          selectedIndex: tabs.indexWhere((d) => d.branch == current),
          onSelect: (i) => _goBranch(tabs[i].branch),
          onPulse: () => showPulseActionSheet(context),
        ),
      );
    }

    final destinations = destinationsFor(role);
    return Scaffold(
      body: Row(
        children: [
          PulseRail(
            destinations: destinations,
            extended: width >= _extendedRailBreakpoint,
            selectedIndex: destinations
                .indexWhere((d) => d.branch == current)
                .clamp(0, destinations.length - 1),
            onSelect: (i) => _goBranch(destinations[i].branch),
            onPulse: () => showPulseActionSheet(context),
          ),
          VerticalDivider(
            width: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
