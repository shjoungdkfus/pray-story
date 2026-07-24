import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';

/// 기도문 관련 로컬 저장소 (SharedPreferences 기반).
///
/// - **draft (B2):** 작성 중 이탈 시 유실 방지용 단일 임시저장.
/// - **cache (B3):** 오프라인 읽기 전용 캐시.
///
/// ⚠️ 기도문 = 민감 개인정보. 로그아웃/탈퇴 시 반드시 [clearAll]로 전부 지운다
/// (평문이 기기에 남으면 FR-007 위반). SPEC 13장 B3 주의사항.
class LocalPrayerStore {
  LocalPrayerStore._();

  static const _draftKey = 'prayer_draft_v1';
  static const _cachePrefix = 'prayer_cache_v1:';

  // ── Draft (B2) ──────────────────────────────────────────────────────────

  /// 신규 작성 중인 내용을 단일 draft로 덮어쓴다.
  static Future<void> saveDraft({
    required String title,
    required String content,
    required DateTime targetDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dayOnly =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    await prefs.setString(
      _draftKey,
      jsonEncode({
        'title': title,
        'content': content,
        'targetDate': dayOnly.toIso8601String(),
        'savedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  static Future<PrayerDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PrayerDraft(
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        targetDate: DateTime.parse(map['targetDate'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  // ── Cache (B3) ──────────────────────────────────────────────────────────

  static String _cacheKey(String userId, String scope) =>
      '$_cachePrefix$userId:$scope';

  /// fetch 성공 시 결과를 로컬에 저장한다.
  static Future<void> writeCache(
    String userId,
    String scope,
    List<PrayerModel> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(userId, scope),
      jsonEncode(list.map((p) => p.toCacheJson()).toList()),
    );
  }

  /// 캐시가 없으면 null. (있어도 파싱 실패 시 null → 폴백 안 함)
  static Future<List<PrayerModel>?> readCache(
    String userId,
    String scope,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(userId, scope));
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => PrayerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// 로그아웃/탈퇴 시 호출. draft + 모든 기도문 캐시를 삭제한다 (보안 요건).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    final cacheKeys =
        prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList();
    for (final k in cacheKeys) {
      await prefs.remove(k);
    }
  }
}

/// 복원된 작성 draft.
class PrayerDraft {
  final String title;
  final String content;
  final DateTime targetDate;

  const PrayerDraft({
    required this.title,
    required this.content,
    required this.targetDate,
  });

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;
}
