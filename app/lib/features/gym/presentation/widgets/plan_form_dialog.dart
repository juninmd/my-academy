import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/gym_providers.dart';
import 'gym_action.dart';

/// Accepts pt-BR ("1.119,90") and plain ("119.9") decimal input.
double? parsePrice(String text) {
  final t = text.trim();
  final normalized =
      t.contains(',') ? t.replaceAll('.', '').replaceAll(',', '.') : t;
  return double.tryParse(normalized);
}

class PlanFormDialog extends HookConsumerWidget {
  const PlanFormDialog({required this.gymId, super.key});
  final int gymId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final name = useTextEditingController();
    final price = useTextEditingController();
    final months = useTextEditingController(text: '1');
    final saving = useState(false);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      saving.value = true;
      final ok = await runGymAction(
        context,
        ref
            .read(gymRepositoryProvider)
            .createPlan(
              gymId,
              name.text.trim(),
              parsePrice(price.text)!,
              int.parse(months.text),
            ),
        success: 'Plano criado',
        onSuccess: () => ref.invalidate(myGymsProvider),
      );
      if (!context.mounted) return;
      ok ? Navigator.of(context).pop() : saving.value = false;
    }

    return AlertDialog(
      title: const Text('Novo plano'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              autofocus: true,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Nome (ex.: Mensal)',
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: r'Preço (R$)',
                hintText: '119,90',
              ),
              validator: (v) {
                final value = parsePrice(v ?? '');
                return value == null || value < 0 ? 'Preço inválido' : null;
              },
            ),
            TextFormField(
              controller: months,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Duração (meses)'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 1 || n > 36
                    ? 'Entre 1 e 36 meses'
                    : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving.value ? null : submit,
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
