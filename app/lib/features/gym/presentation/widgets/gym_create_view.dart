import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/gym_providers.dart';
import 'gym_action.dart';

/// First-run for owners without a gym yet.
class GymCreateView extends HookConsumerWidget {
  const GymCreateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final name = useTextEditingController();
    final address = useTextEditingController();
    final saving = useState(false);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      saving.value = true;
      final address0 = address.text.trim();
      await runGymAction(
        context,
        ref
            .read(gymRepositoryProvider)
            .createGym(name.text.trim(), address0.isEmpty ? null : address0),
        success: 'Academia cadastrada!',
        onSuccess: () => ref.invalidate(myGymsProvider),
      );
      if (context.mounted) saving.value = false;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cadastre sua academia',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Depois você cria planos, matricula alunos e acompanha pagamentos.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Informe o nome'
                              : null,
                ),
                TextFormField(
                  controller: address,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  maxLength: 255,
                  onFieldSubmitted: (_) => submit(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: saving.value ? null : submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Cadastrar academia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
