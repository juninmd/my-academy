import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gym_entities.dart';
import '../providers/gym_providers.dart';
import 'async_list.dart';
import 'enroll_member_dialog.dart';
import 'gym_action.dart';
import 'status_chip.dart';

class GymMembersTab extends ConsumerWidget {
  const GymMembersTab({required this.gym, super.key});
  final GymEntity gym;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void refresh() {
      ref.invalidate(gymMembersProvider(gym.id));
      ref.invalidate(gymDashboardProvider(gym.id));
    }

    Future<void> setStatus(MemberEntity m, String status) => runGymAction(
      context,
      ref
          .read(gymRepositoryProvider)
          .setMemberStatus(gym.id, m.subscriptionId, status),
      success: 'Matrícula ${statusLabel(status).toLowerCase()}',
      onSuccess: refresh,
    );

    return AsyncList<MemberEntity>(
      value: ref.watch(gymMembersProvider(gym.id)),
      onRetry: refresh,
      emptyTitle: 'Nenhum aluno matriculado',
      emptyMessage: 'Matricule alunos pelo e-mail cadastrado no app.',
      header: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed:
                () => showDialog<void>(
                  context: context,
                  builder: (_) => EnrollMemberDialog(gym: gym),
                ),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Matricular aluno'),
          ),
        ),
      ),
      itemBuilder:
          (context, m) => ListTile(
            leading: CircleAvatar(child: Text(m.name.characters.first)),
            title: Text(m.name),
            subtitle: Text(
              [
                m.planName ?? 'Sem plano',
                if (m.endDate != null) 'até ${shortDate.format(m.endDate!)}',
              ].join(' · '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip(m.status),
                PopupMenuButton<String>(
                  tooltip: 'Ações da matrícula',
                  onSelected: (s) => setStatus(m, s),
                  itemBuilder:
                      (_) => [
                        for (final s in const [
                          'ACTIVE',
                          'INACTIVE',
                          'CANCELLED',
                        ])
                          if (s != m.status)
                            PopupMenuItem(
                              value: s,
                              child: Text(
                                'Marcar ${statusLabel(s).toLowerCase()}',
                              ),
                            ),
                      ],
                ),
              ],
            ),
          ),
    );
  }
}
