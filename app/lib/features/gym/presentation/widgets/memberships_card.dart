import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gym_entities.dart';
import '../providers/gym_providers.dart';
import 'status_chip.dart';

/// Student view of their gym enrollments; hidden when there are none.
class MembershipsCard extends ConsumerWidget {
  const MembershipsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(myMembershipsProvider)
        .when(
          data:
              (items) =>
                  items.isEmpty
                      ? const SizedBox.shrink()
                      : Card(
                        margin: const EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Text(
                                'Minhas matrículas',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            for (final m in items) _MembershipTile(m),
                          ],
                        ),
                      ),
          loading: () => const SizedBox.shrink(),
          error:
              (_, _) => const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text('Não foi possível carregar suas matrículas.'),
              ),
        );
  }
}

class _MembershipTile extends StatelessWidget {
  const _MembershipTile(this.m);
  final MembershipEntity m;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (m.planName != null) m.planName!,
      if (m.endDate != null) 'até ${shortDate.format(m.endDate!.toLocal())}',
      if (m.pendingPayments > 0) '${m.pendingPayments} pagamento(s) em aberto',
    ].join(' · ');
    return ListTile(
      leading: const Icon(Icons.store_mall_directory_outlined),
      title: Text(m.gymName),
      subtitle: details.isEmpty ? null : Text(details),
      trailing: StatusChip(m.status),
    );
  }
}
