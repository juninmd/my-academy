import 'package:flutter/material.dart';

Future<void> ConfirmDialog(context, title, content, void Function() onConfirm,
        void Function() onCancel) async =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Sim'),
            onPressed: onConfirm,
          ),
          TextButton(
            child: const Text('Não'),
            onPressed: onCancel,
          ),
        ],
      ),
    );
