import 'package:flutter/material.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sair do Treino?'),
        content: const Text(
          'Se você sair agora, o progresso atual pode não ser salvo completamente. Deseja sair mesmo assim?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar Treinando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      );
    },
  );
  return shouldExit ?? false;
}
