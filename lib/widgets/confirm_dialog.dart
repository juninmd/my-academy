import 'package:flutter/material.dart';

Future<void> ConfirmDialog(
  context,
  title,
  content,
  void Function() onConfirm,
  void Function() onCancel,
) async => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder:
      (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(onPressed: onConfirm, child: const Text('Sim')),
          TextButton(onPressed: onCancel, child: const Text('Não')),
        ],
      ),
);
