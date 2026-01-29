import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';

class PlateCalculatorDialog extends ConsumerStatefulWidget {
  const PlateCalculatorDialog({
    required this.targetWeight,
    this.barWeight,
    super.key,
  });

  final double targetWeight;
  final double? barWeight;

  @override
  ConsumerState<PlateCalculatorDialog> createState() => _PlateCalculatorDialogState();
}

class _PlateCalculatorDialogState extends ConsumerState<PlateCalculatorDialog> {
  late TextEditingController _targetWeightController;
  late TextEditingController _barWeightController;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController(text: widget.targetWeight.toString());

    // Use provided weight, or fetch from settings
    final defaultBarWeight = ref.read(settingsProvider).barWeight;
    _barWeightController = TextEditingController(text: (widget.barWeight ?? defaultBarWeight).toString());
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _barWeightController.dispose();
    super.dispose();
  }

  Map<double, int> _calculatePlates(List<double> availablePlates) {
    final target = double.tryParse(_targetWeightController.text) ?? 0;
    final bar = double.tryParse(_barWeightController.text) ?? 0;

    double remaining = (target - bar) / 2;
    final plates = <double, int>{};

    if (remaining <= 0) return plates;

    for (final plate in availablePlates) {
      final count = (remaining / plate).floor();
      if (count > 0) {
        plates[plate] = count;
        remaining -= count * plate;
      }
    }
    return plates;
  }

  @override
  Widget build(BuildContext context) {
    // Re-calculate on build or listen to controllers. Since we want reactive updates,
    // we can wrap the calculation part in an AnimatedBuilder listening to controllers,
    // or just setState on change. Here, setState on change is simpler.

    final availablePlates = ref.watch(settingsProvider).availablePlates;

    // We can pull values from controllers directly for calculation display.
    final target = double.tryParse(_targetWeightController.text) ?? 0;
    final bar = double.tryParse(_barWeightController.text) ?? 0;
    final weightOnSide = (target - bar) / 2;
    final plates = _calculatePlates(availablePlates);

    return AlertDialog(
      title: const Text('Calculadora de Anilhas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso Total (kg)'),
                    controller: _targetWeightController,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Barra (kg)'),
                     controller: _barWeightController,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Peso por lado: ${weightOnSide > 0 ? weightOnSide.toStringAsFixed(2) : 0} kg',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (weightOnSide <= 0)
               const Text('O peso total deve ser maior que o peso da barra.'),
            if (weightOnSide > 0 && plates.isEmpty)
                const Text('Nenhuma anilha necessária.'),
            ...plates.entries.map((entry) => ListTile(
              leading: CircleAvatar(
                child: Text('${entry.value}'),
              ),
              title: Text('${entry.key} kg'),
              trailing: Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
