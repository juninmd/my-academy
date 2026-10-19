import 'package:flutter/material.dart';

import '../widgets/appearance_card.dart';
import '../widgets/notification_settings_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      letterSpacing: 0.5,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('NOTIFICAÇÕES', style: titleStyle),
          const SizedBox(height: 8),
          const NotificationSettingsCard(),
          const SizedBox(height: 24),
          Text('APARÊNCIA', style: titleStyle),
          const SizedBox(height: 8),
          const AppearanceCard(),
        ],
      ),
    );
  }
}
