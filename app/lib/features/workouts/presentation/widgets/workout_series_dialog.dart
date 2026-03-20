import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WorkoutSeriesDialog extends HookWidget {
  const WorkoutSeriesDialog({
    required this.exerciseName,
    required this.onSave,
    super.key,
  });
  final String exerciseName;
  final Function(int reps, int weight, int rest) onSave;

  @override
  Widget build(BuildContext context) {
    final repsController = useTextEditingController(text: '12');
    final weightController = useTextEditingController(text: '10');
    final restController = useTextEditingController(text: '60');

    return AlertDialog(
      title: Text('Configurar $exerciseName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Repetições'),
          ),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Carga (kg)'),
          ),
          TextField(
            controller: restController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Descanso (s)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final reps = int.tryParse(repsController.text) ?? 0;
            final weight = int.tryParse(weightController.text) ?? 0;
            final rest = int.tryParse(restController.text) ?? 0;
            onSave(reps, weight, rest);
            Navigator.pop(context);
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('exerciseName', exerciseName));
    properties.add(
      ObjectFlagProperty<Function(int reps, int weight, int rest)>.has(
        'onSave',
        onSave,
      ),
    );
  }
}
