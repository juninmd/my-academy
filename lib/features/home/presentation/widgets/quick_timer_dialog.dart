import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuickTimerDialog extends HookConsumerWidget {
  const QuickTimerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default options in seconds
    final options = [30, 60, 90, 120, 180];
    final selectedDuration = useState<int>(60);
    final remaining = useState<int>(0);
    final isRunning = useState<bool>(false);
    final timer = useRef<Timer?>(null);

    void stopTimer() {
      timer.value?.cancel();
      isRunning.value = false;
    }

    void startTimer(int seconds) {
      stopTimer();
      remaining.value = seconds;
      isRunning.value = true;
      timer.value = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remaining.value > 0) {
          remaining.value--;
        } else {
          stopTimer();
          // Could play sound here
        }
      });
    }

    useEffect(() {
      return stopTimer;
    }, []);

    String formatTime(int s) {
      final min = (s ~/ 60).toString().padLeft(2, '0');
      final sec = (s % 60).toString().padLeft(2, '0');
      return '$min:$sec';
    }

    return AlertDialog(
      title: const Text('Descanso Rápido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRunning.value) ...[
            Text(
              formatTime(remaining.value),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value:
                  selectedDuration.value > 0
                      ? remaining.value / selectedDuration.value
                      : 0,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    remaining.value += 10;
                    selectedDuration.value += 10;
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: '+10s',
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: stopTimer,
                  icon: const Icon(Icons.stop),
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  options.map((sec) {
                    return ChoiceChip(
                      label: Text('${sec}s'),
                      selected: selectedDuration.value == sec,
                      onSelected: (sel) {
                        if (sel) selectedDuration.value = sec;
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => startTimer(selectedDuration.value),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
            ),
          ],
        ],
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
