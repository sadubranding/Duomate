import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Local-only review reminders. No server, no account, fully offline —
/// matches DuoMate's "never spammy, always user-controlled" notification rule.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Android 13+ requires this explicit runtime request.
  Future<void> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  /// Schedules (or re-schedules) a single daily reminder at [hour]:00 local
  /// time. Calling this again simply replaces the previous schedule.
  Future<void> scheduleDailyReminder({int hour = 20}) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      1001,
      'DuoMate থেকে মনে করিয়ে দিচ্ছি',
      'আজকের ইংরেজি চর্চাটা বাকি আছে — কয়েক মিনিট সময় দিন।',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_review_reminder',
          'দৈনিক রিভিউ রিমাইন্ডার',
          channelDescription: 'রিভিউ বাকি থাকলে দিনে একবার মনে করিয়ে দেয়',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
