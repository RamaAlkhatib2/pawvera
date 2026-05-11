import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'pawvera_reminders';
  static const _channelName = 'Pet Reminders';

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _ready = true;
  }

  // Unique int ID from reminder doc ID string
  int _notifId(String reminderId) => reminderId.hashCode.abs() % 2000000000;

  Future<void> scheduleReminderNotification({
    required String reminderId,
    required String title,
    required String petName,
    required DateTime scheduledAt,
  }) async {
    if (!_ready) await init();
    if (scheduledAt.isBefore(DateTime.now())) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminders for your pet care schedule',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        _notifId(reminderId),
        title,
        'Time for $title for $petName',
        tz.TZDateTime.from(scheduledAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminderId,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        _notifId(reminderId),
        title,
        'Time for $title for $petName',
        tz.TZDateTime.from(scheduledAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminderId,
      );
    }
  }

  Future<void> cancelNotification(String reminderId) async {
    if (!_ready) await init();
    await _plugin.cancel(_notifId(reminderId));
  }

  Future<void> cancelAllNotifications() async {
    if (!_ready) await init();
    await _plugin.cancelAll();
  }
}
