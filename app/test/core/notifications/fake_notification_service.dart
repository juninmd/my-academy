import 'package:my_academy/core/notifications/notification_service.dart';

class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.permissionGranted = true});

  bool permissionGranted;
  final List<String> calls = [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    calls.add('permission');
    return permissionGranted;
  }

  @override
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async => calls.add('reminder:$hour:$minute');

  @override
  Future<void> cancelWorkoutReminder() async => calls.add('cancelReminder');

  @override
  Future<void> scheduleRestEnd(Duration delay) async =>
      calls.add('rest:${delay.inSeconds}');

  @override
  Future<void> cancelRestEnd() async => calls.add('cancelRest');
}
