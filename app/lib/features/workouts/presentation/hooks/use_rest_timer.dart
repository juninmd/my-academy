import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RestTimerState {
  final ValueNotifier<bool> isActive;
  final ValueNotifier<int> duration;
  final ValueNotifier<int> remaining;
  final void Function(int) start;
  final void Function() stop;

  RestTimerState({
    required this.isActive,
    required this.duration,
    required this.remaining,
    required this.start,
    required this.stop,
  });
}

RestTimerState useRestTimer() {
  final isRestTimerActive = useState(false);
  final restTimerDuration = useState(0);
  final restTimerRemaining = useState(0);
  final restTimer = useRef<Timer?>(null);

  void stopRestTimer() {
    isRestTimerActive.value = false;
    restTimer.value?.cancel();
  }

  void startRestTimer(int duration) {
    stopRestTimer();
    restTimerDuration.value = duration;
    restTimerRemaining.value = duration;
    isRestTimerActive.value = true;

    restTimer.value = Timer.periodic(const Duration(seconds: 1), (
      t,
    ) async {
      if (restTimerRemaining.value > 0) {
        restTimerRemaining.value--;
        if (restTimerRemaining.value <= 3 && restTimerRemaining.value > 0) {
          await HapticFeedback.selectionClick();
        }
      } else {
        stopRestTimer();
        await HapticFeedback.heavyImpact();
      }
    });
  }

  useEffect(() {
    return () {
      stopRestTimer();
    };
  }, []);

  return RestTimerState(
    isActive: isRestTimerActive,
    duration: restTimerDuration,
    remaining: restTimerRemaining,
    start: startRestTimer,
    stop: stopRestTimer,
  );
}
