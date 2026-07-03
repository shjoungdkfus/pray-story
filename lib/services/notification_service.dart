import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../l10n/app_localizations.dart';
import '../models/prayer_alarm_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// context 없는 백그라운드/서비스 코드용 — 저장된 languageProvider 값으로 로케일 결정.
  static Future<AppLocalizations> _l10n() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'ko';
    return lookupAppLocalizations(Locale(code));
  }

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final l = await _l10n();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(AndroidNotificationChannel(
        'pray_story_alarm',
        l.notifChannelPrayerName,
        description: l.notifChannelPrayerDesc,
        importance: Importance.high,
      ));
      await android.createNotificationChannel(AndroidNotificationChannel(
        'pray_story_tomorrow',
        l.notifChannelTomorrowName,
        description: l.notifChannelTomorrowDesc,
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
      final l = await _l10n();
      await _plugin.zonedSchedule(
        _notifId(alarm.id),
        l.notifDailyTitle,
        l.notifDailyBody,
        _nextTime(alarm.hour, alarm.minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pray_story_alarm',
            l.notifChannelPrayerName,
            channelDescription: l.notifChannelPrayerDesc,
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
      final l = await _l10n();
      final tzTime = tz.TZDateTime.from(alarm.alarmTime, tz.local);
      final title =
          alarm.title.isNotEmpty ? alarm.title : l.notifChannelTomorrowName;
      final body = alarm.content.length > 100
          ? '${alarm.content.substring(0, 100)}...'
          : alarm.content;

      await _plugin.zonedSchedule(
        _notifId(alarm.id),
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pray_story_tomorrow',
            l.notifChannelTomorrowName,
            channelDescription: l.notifChannelTomorrowDesc,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: const BigTextStyleInformation(''),
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
