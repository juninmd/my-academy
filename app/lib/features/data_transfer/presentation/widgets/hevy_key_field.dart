import 'package:flutter/material.dart';

/// Asks for a Hevy Pro API key. The key is used once and never stored.
class HevyKeyField extends StatefulWidget {
  const HevyKeyField({
    super.key,
    required this.enabled,
    required this.onSubmit,
  });

  final bool enabled;
  final Future<void> Function(String apiKey) onSubmit;

  @override
  State<HevyKeyField> createState() => _HevyKeyFieldState();
}

class _HevyKeyFieldState extends State<HevyKeyField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    _controller.clear();
    widget.onSubmit(key);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              obscureText: true,
              enabled: widget.enabled,
              decoration: const InputDecoration(
                labelText: 'Chave da API do Hevy Pro',
                helperText: 'Usada só nesta importação; não é guardada.',
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: widget.enabled ? _submit : null,
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }
}
