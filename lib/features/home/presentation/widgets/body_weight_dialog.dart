import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';
import '../../../workouts/presentation/widgets/number_input_control.dart';

class BodyWeightDialog extends HookConsumerWidget {
  const BodyWeightDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentWeight = useState(settings.bodyWeight);

    return AlertDialog(
      title: const Text('Registrar Peso Corporal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Acompanhe sua evolução registrando seu peso atual.'),
          const SizedBox(height: 24),
          NumberInputControl(
            label: 'Peso (kg)',
            value: currentWeight.value.round(),
            step: 1,
            onChanged: (val) {
              currentWeight.value = val.toDouble();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            await ref
                .read(settingsProvider.notifier)
                .setBodyWeight(currentWeight.value);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Peso atualizado para ${currentWeight.value} kg'),
                ),
              );
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
