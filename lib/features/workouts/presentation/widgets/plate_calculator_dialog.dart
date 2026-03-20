import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';

class PlateCalculatorDialog extends StatelessWidget {
  const PlateCalculatorDialog({
    required this.targetWeight,
    this.barWeight,
    super.key,
  });

  final double targetWeight;
  final double? barWeight;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calculadora de Anilhas'),
      content: PlateCalculatorContent(
        targetWeight: targetWeight,
        barWeight: barWeight,
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

class PlateCalculatorContent extends ConsumerStatefulWidget {
  const PlateCalculatorContent({
    required this.targetWeight,
    this.barWeight,
    super.key,
  });

  final double targetWeight;
  final double? barWeight;

  @override
  ConsumerState<PlateCalculatorContent> createState() =>
      _PlateCalculatorContentState();
}

class _PlateCalculatorContentState
    extends ConsumerState<PlateCalculatorContent> {
  late TextEditingController _targetWeightController;
  late TextEditingController _barWeightController;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController(
      text: widget.targetWeight.toString(),
    );

    // Use provided weight, or fetch from settings
    final defaultBarWeight = ref.read(settingsProvider).barWeight;
    _barWeightController = TextEditingController(
      text: (widget.barWeight ?? defaultBarWeight).toString(),
    );
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
    final availablePlates = ref.watch(settingsProvider).availablePlates;
    final target = double.tryParse(_targetWeightController.text) ?? 0;
    final bar = double.tryParse(_barWeightController.text) ?? 0;
    final weightOnSide = (target - bar) / 2;
    final plates = _calculatePlates(availablePlates);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso Total (kg)',
                  ),
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
          if (weightOnSide > 0 && plates.isNotEmpty)
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: BarbellPainter(
                  plates: plates,
                  colorScheme: Theme.of(context).colorScheme,
                ),
              ),
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
          ...plates.entries.map(
            (entry) => ListTile(
              leading: CircleAvatar(child: Text('${entry.value}')),
              title: Text('${entry.key} kg'),
              trailing: Icon(
                Icons.fitness_center,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarbellPainter extends CustomPainter {
  BarbellPainter({required this.plates});

  final Map<double, int> plates;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerY = size.height / 2;

    // Draw Barbell Shaft
    paint.color = Colors.grey[400]!;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.1, centerY),
        width: size.width * 0.2, // Visible part of the bar
        height: 15,
      ),
      paint,
    );

    // Draw Sleeve (Thicker part)
    paint.color = Colors.grey[300]!;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, centerY - 12, size.width * 0.8, 24),
      paint,
    );

    // Draw Plates
    double currentX = size.width * 0.2 + 5; // Start slightly after the sleeve start

    // Order plates from largest to smallest (standard loading)
    final sortedPlates = plates.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    for (final entry in sortedPlates) {
      final weight = entry.key;
      final count = entry.value;

      // Determine height/color based on weight
      final height = _getPlateHeight(weight);
      final color = _getPlateColor(weight);

      for (int i = 0; i < count; i++) {
        paint.color = color;

        // Plate body
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(currentX + 5, centerY), // +5 is half width (10)
            width: 10,
            height: height,
          ),
          paint,
        );

        // Border/Detail
        paint.color = Colors.black.withValues(alpha: 0.1);
        canvas.drawRect(
           Rect.fromCenter(
            center: Offset(currentX + 5, centerY),
            width: 10,
            height: height,
          ),
          Paint()..style = PaintingStyle.stroke..color = Colors.black12..strokeWidth = 1
        );

        currentX += 12; // 10 width + 2 spacing
      }
    }

    // Draw Collar at the end
    paint.color = Colors.grey[700]!;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(currentX + 5, centerY), width: 10, height: 30),
      paint,
    );
  }

  double _getPlateHeight(double weight) {
    if (weight >= 20) return 100;
    if (weight >= 15) return 90;
    if (weight >= 10) return 80;
    if (weight >= 5) return 60;
    return 40;
  }

  Color _getPlateColor(double weight) {
    if (weight >= 25) return Colors.red;
    if (weight >= 20) return Colors.blue;
    if (weight >= 15) return Colors.yellow[700]!;
    if (weight >= 10) return Colors.green;
    if (weight >= 5) return Colors.white;
    if (weight >= 2.5) return Colors.black;
    return Colors.grey;
  }

  @override
  bool shouldRepaint(covariant BarbellPainter oldDelegate) {
    return oldDelegate.plates != plates;
  }
}
