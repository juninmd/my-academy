import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_role.dart';
import 'selection_card.dart';

class RoleStep extends StatelessWidget {
  const RoleStep({required this.onSelected, this.busy = false, super.key});

  final ValueChanged<UserRole> onSelected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Como você vai usar o MyAcademy?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Você pode mudar isso depois no seu perfil.'),
          const SizedBox(height: 32),
          if (busy) const LinearProgressIndicator(),
          for (final role in UserRole.values) ...[
            SelectionCard(
              title: role.label,
              subtitle: role.description,
              icon: _iconOf(role),
              onTap: busy ? () {} : () => onSelected(role),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

IconData _iconOf(UserRole role) => switch (role) {
  UserRole.student => Icons.directions_run,
  UserRole.personal => Icons.sports,
  UserRole.owner => Icons.store_mall_directory_outlined,
};
