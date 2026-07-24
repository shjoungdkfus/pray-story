class PrayerModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? answeredAt;

  bool get isAnswered => answeredAt != null;

  // 과거 날짜 기록은 시간 정보 없이 정오(12:00:00.000)로 저장되는 sentinel 규칙
  static bool isDateOnly(DateTime dt) =>
      dt.hour == 12 && dt.minute == 0 && dt.second == 0 && dt.millisecond == 0;

  const PrayerModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.answeredAt,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) => PrayerModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? '',
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String).toLocal()
            : null,
        answeredAt: json['answered_at'] != null
            ? DateTime.parse(json['answered_at'] as String).toLocal()
            : null,
      );

  Map<String, dynamic> toInsert() => {
        'title': title,
        'content': content,
      };

  // 오프라인 캐시/삭제 Undo용 직렬화. fromJson이 그대로 되읽을 수 있도록
  // Supabase 응답과 동일한 키·UTC ISO 문자열 형태로 내보낸다.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
        'answered_at': answeredAt?.toUtc().toIso8601String(),
      };

  static const _unset = Object();

  PrayerModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    Object? answeredAt = _unset,
  }) =>
      PrayerModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        answeredAt:
            identical(answeredAt, _unset) ? this.answeredAt : answeredAt as DateTime?,
      );
}
