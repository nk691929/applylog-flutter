import 'package:applylog/core/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService implements NotificationRepository {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'follow_up_reminders';
  static const _channelName = 'Follow-up reminders';

  static const _channelDescription =
      'Reminders for job application follow-ups.';

  AndroidNotificationChannel get _followUpChannel =>
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const androidSettings = AndroidInitializationSettings(
      'ic_notifications',
    );

    const iosSettings = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentBanner: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_followUpChannel);
  }

  @override
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final notifGranted = await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    return notifGranted ?? false;
  }

  @override
  Future<void> scheduleFollowUpReminder({
    required int id,
    required String companyName,
    required DateTime scheduledDate,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon:'ic_notifications',
      ),
    );

    final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: 'Follow-up reminder',
      body: 'Time to follow up on your application to $companyName.',
      scheduledDate: scheduled,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}
