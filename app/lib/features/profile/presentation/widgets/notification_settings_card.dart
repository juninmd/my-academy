import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class NotificationSettingsCard extends ConsumerWidget {
  const NotificationSettingsCard({super.key});

  Future<void> _toggle(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await action()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Permita as notificações nas configurações do sistema.',
          ),
        ),
      );
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
      helpText: 'Horário do lembrete',
    );
    if (picked != null) {
      await ref
          .read(settingsProvider.notifier)
          .setReminderTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final time = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    ).format(context);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.alarm_rounded),
            title: const Text('Lembrete de treino'),
            subtitle: const Text('Um aviso diário para você não faltar'),
            value: settings.reminderEnabled,
            onChanged:
                (value) =>
                    _toggle(context, () => notifier.setReminderEnabled(value)),
          ),
          ListTile(
            enabled: settings.reminderEnabled,
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Horário'),
            trailing: Text(
              time,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _pickTime(context, ref),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.timer_outlined),
            title: const Text('Fim do descanso'),
            subtitle: const Text('Avisa quando for hora da próxima série'),
            value: settings.restAlertEnabled,
            onChanged:
                (value) =>
                    _toggle(context, () => notifier.setRestAlertEnabled(value)),
          ),
        ],
      ),
    );
  }
}
