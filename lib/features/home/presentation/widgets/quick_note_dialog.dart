import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/daily_notes_provider.dart';

class QuickNoteDialog extends HookConsumerWidget {
  const QuickNoteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(dailyNotesNotifierProvider);
    final controller = useTextEditingController();
    final selectedMood = useState<String>('💪'); // Default mood

    // Load existing note if available
    useEffect(() {
      if (noteAsync.value != null) {
        controller.text = noteAsync.value!.note;
        selectedMood.value = noteAsync.value!.mood;
      }
      return null;
    }, [noteAsync.value]);

    final moods = ['💪', '😴', '🔥', '🤕', '😊', '😤'];

    return AlertDialog(
      title: const Text('Diário do Atleta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como você está se sentindo hoje?',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Mood Selector
          Center(
            child: Wrap(
              spacing: 12,
              children:
                  moods.map((mood) {
                    final isSelected = selectedMood.value == mood;
                    return InkWell(
                      onTap: () => selectedMood.value = mood,
                      borderRadius: BorderRadius.circular(50),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Text(mood, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notas',
              hintText: 'Ex: Dormi mal, ombro dolorido, muita energia...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
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
            if (controller.text.isNotEmpty) {
              await ref
                  .read(dailyNotesNotifierProvider.notifier)
                  .saveNote(selectedMood.value, controller.text);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Diário atualizado!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
