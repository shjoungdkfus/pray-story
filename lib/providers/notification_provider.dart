import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_alarm_model.dart';
import '../services/notification_service.dart';

class PrayerAlarmsNotifier extends StateNotifier<List<PrayerAlarm>> {
  static const _prefsKey = 'prayer_alarms_v1';

  PrayerAlarmsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      state = [
        PrayerAlarm(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          hour: 6,
          minute: 0,
          enabled: false,
        ),
      ];
      await _persist();
    } else {
      state = (jsonDecode(raw) as List)
          .map((e) => PrayerAlarm.fromJson(e as Map<String, dynamic>))
          .toList();
      await NotificationService.rescheduleAll(state);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> addAlarm(int hour, int minute) async {
    final alarm = PrayerAlarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hour: hour,
      minute: minute,
      enabled: true,
    );
    state = [...state, alarm];
    await _persist();
    await NotificationService.scheduleDaily(alarm);
  }

  Future<void> removeAlarm(String id) async {
    await NotificationService.cancel(id);
    state = state.where((a) => a.id != id).toList();
    await _persist();
  }

  Future<void> toggleAlarm(String id) async {
    state = state.map((a) => a.id == id ? a.copyWith(enabled: !a.enabled) : a).toList();
    await _persist();
    final alarm = state.firstWhere((a) => a.id == id);
    await NotificationService.scheduleDaily(alarm);
  }

  Future<void> updateTime(String id, int hour, int minute) async {
    state = state
        .map((a) => a.id == id ? a.copyWith(hour: hour, minute: minute) : a)
        .toList();
    await _persist();
    final alarm = state.firstWhere((a) => a.id == id);
    await NotificationService.scheduleDaily(alarm);
  }
}

final prayerAlarmsProvider =
    StateNotifierProvider<PrayerAlarmsNotifier, List<PrayerAlarm>>(
  (ref) => PrayerAlarmsNotifier(),
);

class TomorrowAlarmsNotifier extends StateNotifier<List<TomorrowPrayerAlarm>> {
  static const _prefsKey = 'tomorrow_prayer_alarms_v1';

  TomorrowAlarmsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      state = [];
    } else {
      final list = (jsonDecode(raw) as List)
          .map((e) => TomorrowPrayerAlarm.fromJson(e as Map<String, dynamic>))
          .toList();
      final now = DateTime.now();
      state = list.where((a) => a.alarmTime.isAfter(now)).toList();
      await _persist();
      for (final alarm in state) {
        if (alarm.enabled) await NotificationService.scheduleTomorrowPrayer(alarm);
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((a) => a.toJson()).toList()),
    );
  }

  // prayerId 하나에 여러 날짜의 알람을 동시에 둘 수 있다 — 기존 알람을 모두
  // 정리한 뒤 새로 선택된 날짜마다 하나씩 만든다 (휴일은 빼고 특정 날짜만 고르는 식).
  Future<void> addTomorrowAlarm({
    required String prayerId,
    required String title,
    required String content,
    required List<DateTime> alarmTimes,
  }) async {
    await cancelAlarm(prayerId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final alarms = alarmTimes
        .map((t) => TomorrowPrayerAlarm(
              id: '${now}_${t.millisecondsSinceEpoch}',
              prayerId: prayerId,
              title: title,
              content: content,
              alarmTime: t,
              enabled: true,
            ))
        .toList();
    state = [...state, ...alarms];
    await _persist();
    for (final alarm in alarms) {
      await NotificationService.scheduleTomorrowPrayer(alarm);
    }
  }

  Future<void> cancelAlarm(String prayerId) async {
    final matching = state.where((a) => a.prayerId == prayerId).toList();
    if (matching.isEmpty) return;
    for (final alarm in matching) {
      await NotificationService.cancelTomorrowPrayer(alarm.id);
    }
    state = state.where((a) => a.prayerId != prayerId).toList();
    await _persist();
  }

  bool hasAlarmForPrayer(String prayerId) {
    return state.any((a) => a.prayerId == prayerId && a.enabled);
  }
}

final tomorrowAlarmsProvider =
    StateNotifierProvider<TomorrowAlarmsNotifier, List<TomorrowPrayerAlarm>>(
  (ref) => TomorrowAlarmsNotifier(),
);
