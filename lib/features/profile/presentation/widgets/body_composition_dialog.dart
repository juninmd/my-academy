import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../utils/body_composition_calculator.dart';

class BodyCompositionDialog extends HookWidget {
  const BodyCompositionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 0 = Men, 1 = Women
    final genderIndex = useState(0);
    final ageController = useTextEditingController();

    // Skinfolds (mm)
    final chestController = useTextEditingController();
    final axillaController = useTextEditingController();
    final tricepsController = useTextEditingController();
    final subscapularController = useTextEditingController();
    final abdominalController = useTextEditingController();
    final suprailiacController = useTextEditingController();
    final thighController = useTextEditingController();

    final result = useState<double?>(null);

    void calculate() {
      final age = int.tryParse(ageController.text) ?? 0;
      final chest = double.tryParse(chestController.text) ?? 0;
      final axilla = double.tryParse(axillaController.text) ?? 0;
      final triceps = double.tryParse(tricepsController.text) ?? 0;
      final subscapular = double.tryParse(subscapularController.text) ?? 0;
      final abdominal = double.tryParse(abdominalController.text) ?? 0;
      final suprailiac = double.tryParse(suprailiacController.text) ?? 0;
      final thigh = double.tryParse(thighController.text) ?? 0;

      if (age <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, insira uma idade válida.')),
        );
        return;
      }

      double density;
      if (genderIndex.value == 0) {
        // Men
        density = BodyCompositionCalculator.calculateBodyDensityMen(
          chest: chest,
          axilla: axilla,
          triceps: triceps,
          subscapular: subscapular,
          abdominal: abdominal,
          suprailiac: suprailiac,
          thigh: thigh,
          age: age,
        );
      } else {
        // Women
        density = BodyCompositionCalculator.calculateBodyDensityWomen(
          chest: chest,
          axilla: axilla,
          triceps: triceps,
          subscapular: subscapular,
          abdominal: abdominal,
          suprailiac: suprailiac,
          thigh: thigh,
          age: age,
        );
      }

      final fatPercentage = BodyCompositionCalculator.calculateBodyFatPercentage(density);
      result.value = fatPercentage;
    }

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculadora de Gordura Corporal',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Protocolo Pollock 7 dobras',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Gender Toggle
            SegmentedButton<int>(
              segments: const [
                 ButtonSegment(value: 0, label: Text('Homem'), icon: Icon(Icons.male)),
                 ButtonSegment(value: 1, label: Text('Mulher'), icon: Icon(Icons.female)),
              ],
              selected: {genderIndex.value},
              onSelectionChanged: (newSelection) {
                genderIndex.value = newSelection.first;
              },
            ),
            const SizedBox(height: 16),

            _buildInput(context, 'Idade (anos)', ageController),
            const Divider(),
            Text('Dobras Cutâneas (mm)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInput(context, 'Peitoral', chestController),
            _buildInput(context, 'Axilar Média', axillaController),
            _buildInput(context, 'Tríceps', tricepsController),
            _buildInput(context, 'Subescapular', subscapularController),
            _buildInput(context, 'Abdominal', abdominalController),
            _buildInput(context, 'Supra-ilíaca', suprailiacController),
            _buildInput(context, 'Coxa', thighController),

            const SizedBox(height: 24),

            if (result.value != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Gordura Corporal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${result.value!.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: calculate,
              child: const Text('Calcular'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
