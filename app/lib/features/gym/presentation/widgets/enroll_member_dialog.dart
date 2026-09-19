import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/gym_entities.dart';
import '../providers/gym_providers.dart';
import 'gym_action.dart';
import 'status_chip.dart';

class EnrollMemberDialog extends HookConsumerWidget {
  const EnrollMemberDialog({required this.gym, super.key});
  final GymEntity gym;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final email = useTextEditingController();
    final planId = useState<int?>(gym.plans.firstOrNull?.id);
    final saving = useState(false);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      saving.value = true;
      final ok = await runGymAction(
        context,
        ref
            .read(gymRepositoryProvider)
            .enroll(gym.id, email.text.trim(), planId.value!),
        success: 'Aluno matriculado',
        onSuccess: () {
          ref.invalidate(gymMembersProvider(gym.id));
          ref.invalidate(gymPaymentsProvider(gym.id));
          ref.invalidate(gymDashboardProvider(gym.id));
        },
      );
      if (!context.mounted) return;
      ok ? Navigator.of(context).pop() : saving.value = false;
    }

    return AlertDialog(
      title: const Text('Matricular aluno'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail do aluno',
                  helperText: 'O aluno precisa ter acessado o app uma vez.',
                  helperMaxLines: 2,
                ),
                validator:
                    (v) =>
                        (v != null &&
                                RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim()))
                            ? null
                            : 'E-mail inválido',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: planId.value,
                decoration: const InputDecoration(labelText: 'Plano'),
                items: [
                  for (final p in gym.plans)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} · ${brl.format(p.price)}'),
                    ),
                ],
                onChanged: (v) => planId.value = v,
                validator: (v) => v == null ? 'Crie um plano primeiro' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving.value ? null : submit,
          child: const Text('Matricular'),
        ),
      ],
    );
  }
}
