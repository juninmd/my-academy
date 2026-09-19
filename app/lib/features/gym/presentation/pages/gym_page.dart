import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/widgets/common_empty_state.dart';
import '../../domain/entities/gym_entities.dart';
import '../providers/gym_providers.dart';
import '../widgets/gym_create_view.dart';
import '../widgets/gym_kpis.dart';
import '../widgets/gym_members_tab.dart';
import '../widgets/gym_payments_tab.dart';
import '../widgets/gym_plans_tab.dart';

/// Owner area: KPIs plus members, payments and plans management.
class GymPage extends ConsumerWidget {
  const GymPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyms = ref.watch(myGymsProvider);
    return gyms.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            body: CommonEmptyState(
              icon: Icons.cloud_off,
              title: 'Não foi possível carregar sua academia',
              message: e is Failure ? e.message : '$e',
              actionLabel: 'Tentar novamente',
              onAction: () => ref.invalidate(myGymsProvider),
            ),
          ),
      data:
          (list) =>
              list.isEmpty
                  ? Scaffold(
                    appBar: AppBar(title: const Text('Academia')),
                    body: const GymCreateView(),
                  )
                  : _GymDashboard(gym: list.first),
    );
  }
}

class _GymDashboard extends StatelessWidget {
  const _GymDashboard({required this.gym});
  final GymEntity gym;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gym.name),
              if (gym.address != null)
                Text(
                  gym.address!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: GymKpis(gymId: gym.id),
                ),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.groups_outlined), text: 'Alunos'),
                    Tab(
                      icon: Icon(Icons.payments_outlined),
                      text: 'Pagamentos',
                    ),
                    Tab(icon: Icon(Icons.sell_outlined), text: 'Planos'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      GymMembersTab(gym: gym),
                      GymPaymentsTab(gymId: gym.id),
                      GymPlansTab(gym: gym),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
