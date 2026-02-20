import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/exercise_entity.dart';
import '../providers/custom_exercise_provider.dart';
import '../providers/workout_create_provider.dart';

class AddCustomExerciseDialog extends HookConsumerWidget {
  const AddCustomExerciseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final selectedGroup = useState('Outros');
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final muscleGroups = [
      'Peito',
      'Costas',
      'Pernas',
      'Ombros',
      'Bíceps',
      'Tríceps',
      'Core',
      'Outros',
    ];

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      try {
        final id = DateTime.now().millisecondsSinceEpoch; // Unique ID
        // Note: Using a large positive ID. Ensure backend IDs don't conflict (usually they are small incrementing ints).

        // Append selected group to description for reference
        final desc = descriptionController.text.trim();
        final fullDesc = desc.isNotEmpty
            ? '$desc\n\nGrupo Muscular: ${selectedGroup.value}'
            : 'Grupo Muscular: ${selectedGroup.value}';

        final exercise = ExerciseEntity(
          id: id,
          name: nameController.text.trim(),
          description: fullDesc,
        );

        // However, to make filters work in Library, the mapper needs keywords.
        // I'll append the group to the description for reference.
        // And maybe the user should include keywords in the name.

        await ref.read(customExerciseRepositoryProvider).saveCustomExercise(exercise);

        // Refresh the provider
        ref.invalidate(exercisesProvider);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercício criado com sucesso!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: const Text('Criar Exercício'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  hintText: 'Ex: Supino Invertido',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedGroup.value,
                decoration: const InputDecoration(
                  labelText: 'Grupo Muscular (Referência)',
                  border: OutlineInputBorder(),
                ),
                items: muscleGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => selectedGroup.value = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dica: Inclua palavras-chave como "Supino" ou "Agachamento" no nome para categorização automática.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isLoading.value ? null : save,
          child: isLoading.value
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Salvar'),
        ),
      ],
    );
  }
}
