import 'package:flutter/material.dart';

class RpeInfoDialog extends StatelessWidget {
  const RpeInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escala RPE (Percepção Subjetiva de Esforço)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A escala RPE (Rate of Perceived Exertion) mede a intensidade do exercício baseada em quantas repetições você ainda conseguiria fazer.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildRpeRow(
              context,
              10,
              'Esforço Máximo',
              '0 repetições na reserva (RIR)',
            ),
            _buildRpeRow(context, 9, 'Muito Difícil', '1 repetição na reserva'),
            _buildRpeRow(context, 8, 'Difícil', '2 repetições na reserva'),
            _buildRpeRow(
              context,
              7,
              'Moderado/Difícil',
              '3 repetições na reserva',
            ),
            _buildRpeRow(context, 6, 'Moderado', '4 repetições na reserva'),
            _buildRpeRow(
              context,
              5,
              'Moderado/Fácil',
              'Esforço de aquecimento',
            ),
            _buildRpeRow(context, 4, 'Fácil', 'Recuperação ativa'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendi'),
        ),
      ],
    );
  }

  Widget _buildRpeRow(
    BuildContext context,
    int rpe,
    String title,
    String desc,
  ) {
    Color color;
    if (rpe >= 9) {
      color = Colors.red;
    } else if (rpe >= 7) {
      color = Colors.orange;
    } else if (rpe >= 5) {
      color = Colors.yellow.shade700;
    } else {
      color = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color),
            ),
            child: Text(
              '$rpe',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
