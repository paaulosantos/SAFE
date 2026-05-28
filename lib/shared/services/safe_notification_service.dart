import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SafeNotificationService {
  SafeNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeAndScheduleDailyQuiz() async {
    if (kIsWeb) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Maceio'));

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _notifications.initialize(settings: initializationSettings);
      await _requestPermissions();
      await _scheduleDailyQuizReminder();
    } catch (_) {
      // Notification plugins can be unavailable in tests/desktops; the app must
      // remain usable even when reminders are not supported.
    }
  }

  static Future<void> _requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _scheduleDailyQuizReminder() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'safe_daily_quiz',
        'Lembrete do quiz diario',
        channelDescription: 'Lembrete diario para responder o quiz do SAFE.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id: 1001,
      title: 'Quiz diario do SAFE',
      body: 'Responda o desafio de hoje e mantenha seu streak de seguranca.',
      scheduledDate: _nextQuizReminderTime(),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextQuizReminderTime() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
