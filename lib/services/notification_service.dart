import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'cache_service.dart';

/// Service responsible for managing local notifications.
/// Sends daily training reminders if the user hasn't trained.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final CacheService _cacheService = CacheService();

  static const int _trainingReminderId = 1;
  static const String _channelId = 'training_reminders';
  static const String _channelName = 'Lembretes de Treino';
  static const String _channelDescription =
      'Notificações para lembrar de treinar';

  /// Initializes the notification service. Must be called at app startup.
  Future<void> init() async {
    // Skip initialization on web as notifications aren't supported
    if (kIsWeb) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    if (!kIsWeb && Platform.isAndroid) {
      await _requestAndroidPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific page
    // For now, just opening the app is sufficient
  }

  /// Schedules a daily training reminder at 18:00 (6 PM).
  Future<void> scheduleDailyTrainingReminder() async {
    if (kIsWeb) return;

    // Cancel existing reminder to avoid duplicates
    await cancelTrainingReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 6 PM
      0,
    );

    // If 6 PM has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _trainingReminderId,
      '💪 Hora de treinar!',
      'Você ainda não treinou hoje. Vamos manter a sequência?',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels the training reminder notification.
  Future<void> cancelTrainingReminder() async {
    if (kIsWeb) return;
    await _notifications.cancel(_trainingReminderId);
  }

  /// Check if user should receive notification based on training status.
  /// Called when the app is opened.
  Future<void> checkAndUpdateNotifications() async {
    if (kIsWeb) return;

    if (_cacheService.hasTrainedToday()) {
      // User already trained today, cancel reminder
      await cancelTrainingReminder();
    } else {
      // User hasn't trained, schedule reminder
      await scheduleDailyTrainingReminder();
    }
  }

  /// Called when user completes a training session.
  Future<void> onTrainingCompleted() async {
    await _cacheService.markTrainingCompleted();
    await cancelTrainingReminder();
  }

  /// Shows an immediate notification (useful for testing).
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(0, title, body, notificationDetails);
  }
}
