class PrayerAlarm {
  final String id;
  final int hour;
  final int minute;
  final bool enabled;
  final String? prayerTitle;
  final String? prayerId;

  const PrayerAlarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.enabled,
    this.prayerTitle,
    this.prayerId,
  });

  PrayerAlarm copyWith({
    int? hour,
    int? minute,
    bool? enabled,
    String? prayerTitle,
    String? prayerId,
  }) =>
      PrayerAlarm(
        id: id,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        enabled: enabled ?? this.enabled,
        prayerTitle: prayerTitle ?? this.prayerTitle,
        prayerId: prayerId ?? this.prayerId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        if (prayerTitle != null) 'prayer_title': prayerTitle,
        if (prayerId != null) 'prayer_id': prayerId,
      };

  factory PrayerAlarm.fromJson(Map<String, dynamic> json) => PrayerAlarm(
        id: json['id'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        enabled: json['enabled'] as bool,
        prayerTitle: json['prayer_title'] as String?,
        prayerId: json['prayer_id'] as String?,
      );
}

class TomorrowPrayerAlarm {
  final String id;
  final String prayerId;
  final String title;
  final String content;
  final DateTime alarmTime;
  final bool enabled;

  const TomorrowPrayerAlarm({
    required this.id,
    required this.prayerId,
    required this.title,
    required this.content,
    required this.alarmTime,
    required this.enabled,
  });

  TomorrowPrayerAlarm copyWith({DateTime? alarmTime, bool? enabled}) =>
      TomorrowPrayerAlarm(
        id: id,
        prayerId: prayerId,
        title: title,
        content: content,
        alarmTime: alarmTime ?? this.alarmTime,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'prayer_id': prayerId,
        'title': title,
        'content': content,
        'alarm_time': alarmTime.toIso8601String(),
        'enabled': enabled,
      };

  factory TomorrowPrayerAlarm.fromJson(Map<String, dynamic> json) =>
      TomorrowPrayerAlarm(
        id: json['id'] as String,
        prayerId: json['prayer_id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        alarmTime: DateTime.parse(json['alarm_time'] as String),
        enabled: json['enabled'] as bool,
      );
}
