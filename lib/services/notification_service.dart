import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_alarm_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(
        'pray_story_alarm',
        '기도 알림',
        description: '기도 제목 알림',
        importance: Importance.high,
      ));
      await android.createNotificationChannel(const AndroidNotificationChannel(
        'pray_story_tomorrow',
        '내일을 위한 기도',
        description: '내일을 위해 작성한 기도 제목 알림',
        importance: Importance.high,
      ));
    }
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  static Future<void> scheduleDaily(PrayerAlarm alarm) async {
    if (!alarm.enabled) {
      await cancel(alarm.id);
      return;
    }
    try {
      await _plugin.zonedSchedule(
        _notifId(alarm.id),
        '기도 시간이에요',
        '오늘을 위한 기도 제목을 확인해 보세요.',
        _nextTime(alarm.hour, alarm.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pray_story_alarm',
            '기도 알림',
            channelDescription: '기도 제목 알림',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  static Future<void> cancel(String alarmId) async {
    await _plugin.cancel(_notifId(alarmId));
  }

  static Future<void> rescheduleAll(List<PrayerAlarm> alarms) async {
    await _plugin.cancelAll();
    for (final alarm in alarms) {
      if (alarm.enabled) await scheduleDaily(alarm);
    }
  }

  static Future<void> scheduleTomorrowPrayer(TomorrowPrayerAlarm alarm) async {
    if (!alarm.enabled) {
      await cancelTomorrowPrayer(alarm.id);
      return;
    }
    try {
      final tzTime = tz.TZDateTime.from(alarm.alarmTime, tz.local);
      final title = alarm.title.isNotEmpty ? alarm.title : '내일을 위한 기도';
      final body = alarm.content.length > 100
          ? '${alarm.content.substring(0, 100)}...'
          : alarm.content;

      await _plugin.zonedSchedule(
        _notifId(alarm.id),
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pray_story_tomorrow',
            '내일을 위한 기도',
            channelDescription: '내일을 위해 작성한 기도 제목 알림',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> cancelTomorrowPrayer(String alarmId) async {
    await _plugin.cancel(_notifId(alarmId));
  }

  static tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  static int _notifId(String id) => id.hashCode.abs() % 2147483647;
}
