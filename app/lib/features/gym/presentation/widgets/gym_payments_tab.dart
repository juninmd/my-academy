import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gym_entities.dart';
import '../providers/gym_providers.dart';
import 'async_list.dart';
import 'gym_action.dart';
import 'status_chip.dart';

class GymPaymentsTab extends ConsumerWidget {
  const GymPaymentsTab({required this.gymId, super.key});
  final int gymId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void refresh() {
      ref.invalidate(gymPaymentsProvider(gymId));
      ref.invalidate(gymDashboardProvider(gymId));
    }

    Future<void> setStatus(PaymentEntity p, String status) => runGymAction(
      context,
      ref.read(gymRepositoryProvider).setPaymentStatus(gymId, p.id, status),
      success: 'Pagamento: ${statusLabel(status).toLowerCase()}',
      onSuccess: refresh,
    );

    return AsyncList<PaymentEntity>(
      value: ref.watch(gymPaymentsProvider(gymId)),
      onRetry: refresh,
      emptyTitle: 'Nenhum pagamento',
      emptyMessage: 'Cada matrícula gera uma cobrança pendente.',
      itemBuilder:
          (context, p) => ListTile(
            title: Text('${p.memberName} · ${brl.format(p.amount)}'),
            subtitle: Text(
              [
                if (p.planName != null) p.planName!,
                shortDate.format(p.date),
              ].join(' · '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip(p.status),
                if (p.status != 'PAID')
                  IconButton(
                    tooltip: 'Marcar como pago',
                    icon: const Icon(Icons.price_check),
                    onPressed: () => setStatus(p, 'PAID'),
                  ),
                if (p.status == 'PENDING')
                  IconButton(
                    tooltip: 'Marcar como atrasado',
                    icon: const Icon(Icons.alarm_off),
                    onPressed: () => setStatus(p, 'OVERDUE'),
                  ),
              ],
            ),
          ),
    );
  }
}
