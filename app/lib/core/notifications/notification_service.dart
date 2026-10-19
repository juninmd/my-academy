import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';

/// Contrato para notificações locais (lembrete diário e fim do descanso).
abstract class NotificationService {
  /// Prepara o plugin e o fuso horário local. Seguro chamar mais de uma vez.
  Future<void> init();

  /// Pede permissão ao usuário. Retorna `true` quando concedida.
  Future<bool> requestPermission();

  /// Agenda um lembrete de treino que se repete todos os dias.
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  });

  Future<void> cancelWorkoutReminder();

  /// Avisa que o descanso entre séries terminou, mesmo com o app em segundo plano.
  Future<void> scheduleRestEnd(Duration delay);

  Future<void> cancelRestEnd();
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(),
);

/// Próximo instante em que [hour]:[minute] ocorre, a partir de [now].
DateTime nextOccurrence(DateTime now, int hour, int minute) {
  final today = DateTime(now.year, now.month, now.day, hour, minute);
  return today.isAfter(now) ? today : today.add(const Duration(days: 1));
}
