import 'package:flutter/material.dart';
import 'timer_notifier.dart';

class WorkoutTimer extends StatelessWidget {
  const WorkoutTimer({required this.notifier, super.key});
  final TimerNotifier notifier;

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Text(
          _formatTime(value),
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        );
      },
    );
  }
}
