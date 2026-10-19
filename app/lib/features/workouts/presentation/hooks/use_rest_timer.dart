import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/notifications/notification_service.dart';

class RestTimerState {
  final ValueNotifier<bool> isActive;
  final ValueNotifier<int> duration;
  final ValueNotifier<int> remaining;
  final void Function(int) start;
  final void Function() stop;
  final void Function(int) extend;

  RestTimerState({
    required this.isActive,
    required this.duration,
    required this.remaining,
    required this.start,
    required this.stop,
    required this.extend,
  });
}

/// Quando [notifications] é informado, agenda um aviso para o fim do descanso
/// (útil com o app em segundo plano).
RestTimerState useRestTimer({NotificationService? notifications}) {
  final isRestTimerActive = useState(false);
  final restTimerDuration = useState(0);
  final restTimerRemaining = useState(0);
  final restTimer = useRef<Timer?>(null);

  void scheduleAlert(int seconds) {
    if (notifications == null) return;
    unawaited(
      notifications
          .scheduleRestEnd(Duration(seconds: seconds))
          .catchError((Object _) {}),
    );
  }

  void stopRestTimer() {
    isRestTimerActive.value = false;
    restTimer.value?.cancel();
    if (notifications != null) {
      unawaited(notifications.cancelRestEnd().catchError((Object _) {}));
    }
  }

  void extendRestTimer(int seconds) {
    restTimerRemaining.value += seconds;
    restTimerDuration.value += seconds;
    scheduleAlert(restTimerRemaining.value);
  }

  void startRestTimer(int duration) {
    stopRestTimer();
    restTimerDuration.value = duration;
    restTimerRemaining.value = duration;
    isRestTimerActive.value = true;
    scheduleAlert(duration);

    restTimer.value = Timer.periodic(const Duration(seconds: 1), (t) async {
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
    extend: extendRestTimer,
  );
}
