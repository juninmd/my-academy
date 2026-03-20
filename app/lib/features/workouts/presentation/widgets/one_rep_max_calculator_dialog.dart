import 'package:flutter/material.dart';

import '../../../../utils/one_rep_max_calculator.dart';

class OneRepMaxCalculatorDialog extends StatefulWidget {
  const OneRepMaxCalculatorDialog({super.key});

  @override
  State<OneRepMaxCalculatorDialog> createState() =>
      _OneRepMaxCalculatorDialogState();
}

class _OneRepMaxCalculatorDialogState extends State<OneRepMaxCalculatorDialog> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  double _oneRepMax = 0;

  void _calculate() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    setState(() {
      _oneRepMax = OneRepMaxCalculator.calculateEpley(weight, reps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calculadora 1RM'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Estime sua repetição máxima (Epley).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carga (kg)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Repetições',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            if (_oneRepMax > 0)
              Column(
                children: [
                  Text(
                    '${_oneRepMax.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('1RM Estimado'),
                  const SizedBox(height: 16),
                  // Percentages table
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    children: [
                      _buildPercentageRow('95%', 0.95),
                      _buildPercentageRow('90%', 0.90),
                      _buildPercentageRow('85%', 0.85),
                      _buildPercentageRow('80%', 0.80),
                      _buildPercentageRow('75%', 0.75),
                      _buildPercentageRow('70%', 0.70),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  TableRow _buildPercentageRow(String label, double percentage) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${(_oneRepMax * percentage).toStringAsFixed(1)} kg',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
