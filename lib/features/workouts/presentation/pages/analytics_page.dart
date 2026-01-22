import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, we would fetch historical data here.
    // For now, we will mock data to demonstrate the UI capability.

    return Scaffold(
      appBar: AppBar(title: const Text('Análise de Progresso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildChartSection(
              context,
              title: 'Treinos por Semana',
              child: const _SimpleBarChart(
                data: [3, 4, 2, 5, 3, 4, 5],
                labels: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              title: 'Volume Estimado (Ton)',
              child: const _SimpleBarChart(
                data: [5.2, 6.1, 4.5, 7.0, 5.5, 6.2, 0.0],
                labels: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
                color: Colors.orange,
              ),
            ),
             const SizedBox(height: 24),
             const Card(
               child: Padding(
                 padding: EdgeInsets.all(16),
                 child: Column(
                   children: [
                     Icon(Icons.info_outline, size: 40, color: Colors.grey),
                     SizedBox(height: 16),
                     Text(
                       'Dados detalhados estarão disponíveis conforme você realiza seus treinos.',
                       textAlign: TextAlign.center,
                     ),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color;

  const _SimpleBarChart({
    required this.data,
    required this.labels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.reduce((curr, next) => curr > next ? curr : next);
    // Avoid division by zero
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(data.length, (index) {
        final heightFactor = data[index] / safeMax;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            Flexible(
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              labels[index],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }
}
