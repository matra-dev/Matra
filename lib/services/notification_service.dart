import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../models/supplement_model.dart';

/// Local notification service for supplement dose reminders.
/// Works completely offline — schedules are stored locally.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(initSettings);

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'supplement_reminders',
      'Supplement Reminders',
      description: 'Daily reminders to take your supplements',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return await Permission.notification.isGranted;
  }

  /// Schedule a daily recurring reminder for a specific time.
  Future<void> scheduleSupplementReminder({
    required int id,
    required String supplementName,
    required String dosage,
    required int hour,
    required int minute,
    required String slotName,
  }) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      'Time for $supplementName',
      '$dosage · $slotName',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'supplement_reminders',
          'Supplement Reminders',
          channelDescription: 'Daily reminders to take your supplements',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule reminders for all supplements based on their time slots.
  Future<void> scheduleAllSupplementReminders(List<Supplement> supplements) async {
    await cancelAllSupplementReminders();

    var notificationId = 1000;
    for (final supp in supplements) {
      for (final slot in supp.timeSlots) {
        final hourMinute = _slotToTime(slot);
        if (hourMinute != null) {
          await scheduleSupplementReminder(
            id: notificationId++,
            supplementName: supp.name,
            dosage: supp.dosageText,
            hour: hourMinute.$1,
            minute: hourMinute.$2,
            slotName: slot,
          );
        }
      }
    }
  }

  /// Show a stock alert notification.
  Future<void> showStockAlert({required String supplementName, required int remaining}) async {
    if (!_initialized) await init();

    await _notifications.show(
      math.Random().nextInt(100000),
      'Low Stock: $supplementName',
      'Only $remaining left. Remember to refill.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'stock_alerts',
          'Stock Alerts',
          channelDescription: 'Alerts when supplement stock is low',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancel all supplement reminders.
  Future<void> cancelAllSupplementReminders() async {
    if (!_initialized) await init();
    await _notifications.cancelAll();
  }

  /// Cancel a specific reminder by ID.
  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  /// Map time slot names to hour/minute.
  (int, int)? _slotToTime(String slot) {
    return switch (slot.toLowerCase()) {
      'morning' => (8, 0),
      'afternoon' => (13, 0),
      'evening' => (20, 0),
      _ => null,
    };
  }
}
