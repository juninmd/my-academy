import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RestTimerDialog extends HookWidget {
  const RestTimerDialog({
    required this.initialDuration,
    required this.onComplete,
    super.key,
  });
  final int initialDuration;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final duration = useState(initialDuration);
    final remaining = useState(initialDuration);
    final timer = useRef<Timer?>(null);

    void stopTimer() {
      timer.value?.cancel();
    }

    void startTimer() {
      stopTimer();
      timer.value = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remaining.value > 0) {
          remaining.value--;
        } else {
          stopTimer();
          Navigator.of(context).pop(); // Close dialog
          onComplete();
        }
      });
    }

    useEffect(() {
      startTimer();
      return stopTimer;
    }, []);

    final progress = remaining.value / duration.value;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Descanso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                '${remaining.value}s',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  duration.value += 10;
                  remaining.value += 10;
                },
                child: const Text('+10s'),
              ),
              ElevatedButton(
                onPressed: () {
                  stopTimer();
                  Navigator.of(context).pop();
                },
                child: const Text('Pular'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
