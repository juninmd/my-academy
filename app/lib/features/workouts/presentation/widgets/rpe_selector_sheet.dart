import 'package:flutter/material.dart';

class RpeSelectorSheet extends StatelessWidget {
  const RpeSelectorSheet({required this.onSelected, super.key});

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensidade (RPE)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Fechar',
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quão difícil foi essa série?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final rpe = index + 1;
              final color = _getRpeColor(rpe);
              return InkWell(
                onTap: () {
                  onSelected(rpe);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$rpe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fácil',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
              Text(
                'Moderado',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
              Text('Máximo', style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Guia de Esforço:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGuideRow(context, '10', 'Falha Concêntrica / 0 RIR'),
          _buildGuideRow(context, '9', 'Difícil (1 Rep na Reserva)'),
          _buildGuideRow(context, '8', 'Moderado (2 Reps na Reserva)'),
          _buildGuideRow(context, '7', 'Controle (3 Reps na Reserva)'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuideRow(BuildContext context, String rpe, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getRpeColor(int.parse(rpe)).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rpe,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getRpeColor(int.parse(rpe)),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(desc, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 4) return Colors.green;
    if (rpe <= 7) return Colors.orange;
    return Colors.red;
  }
}
