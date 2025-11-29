import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification clicked: ${response.payload}");
        // TODO: Navigate to contact detail
      },
    );
  }

  Future<void> scheduleFollowUp({
    required int id,
    required String name,
    required DateTime scheduledDate,
    String? body,
  }) async {
    // Ensure scheduled date is in the future
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      await _notifications.zonedSchedule(
        id,
        'Follow up with $name',
        body ?? 'It\'s time to reconnect with $name!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'follow_ups',
            'Follow Ups',
            channelDescription: 'Reminders to reconnect with contacts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Scheduled notification for $name at $scheduledDate");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}