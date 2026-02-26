import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class QuickNoteDialog extends HookWidget {
  const QuickNoteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return AlertDialog(
      title: const Text('Diário Rápido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Registre como você está se sentindo ou anotações para hoje.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ex: Dormi mal, ombro dolorido...',
              border: OutlineInputBorder(),
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
          onPressed: () {
            if (controller.text.isNotEmpty) {
              // TODO: Save to repository
              debugPrint('Nota salva (Simulação): ${controller.text}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nota registrada! (Funcionalidade em breve)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
