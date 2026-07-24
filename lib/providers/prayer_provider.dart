import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prayer_model.dart';
import '../services/local_prayer_store.dart';
import 'auth_provider.dart';

// ── 오프라인 상태 (B3) ─────────────────────────────────────────────────────────
// 네트워크 실패로 캐시 폴백이 일어나면 true. 성공적으로 다시 불러오면 false.
// UI 배지가 이 값을 watch 한다.
final isOfflineProvider = StateProvider<bool>((ref) => false);

// provider build 중 다른 provider를 직접 수정하면 안 되므로 microtask로 지연한다.
// autoDispose로 이미 폐기된 뒤일 수 있어 try/catch로 감싼다.
void _markOffline(Ref ref, bool offline) {
  Future.microtask(() {
    try {
      final notifier = ref.read(isOfflineProvider.notifier);
      if (notifier.state != offline) notifier.state = offline;
    } catch (_) {
      // provider가 이미 폐기됨 — 무시.
    }
  });
}

/// 삭제된 기도문을 원본 필드를 보존해 재insert 한다 (B1 Undo).
/// id는 서버가 새로 발급하지만 created_at/answered_at은 원본을 유지해
/// 같은 날짜/응답 상태로 되살아난다.
Future<void> restorePrayer(SupabaseClient supabase, PrayerModel prayer) async {
  await supabase.from('prayers').insert({
    'user_id': prayer.userId,
    'title': prayer.title,
    'content': prayer.content,
    'created_at': prayer.createdAt.toUtc().toIso8601String(),
    if (prayer.answeredAt != null)
      'answered_at': prayer.answeredAt!.toUtc().toIso8601String(),
  });
}

// ── 기존 Provider ─────────────────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final prayersForDateProvider =
    FutureProvider.autoDispose.family<List<PrayerModel>, DateTime>(
  (ref, date) async {
    final supabase = ref.watch(supabaseProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final scope = 'date:${start.toIso8601String()}';

    try {
      final res = await supabase
          .from('prayers')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', start.toUtc().toIso8601String())
          .lt('created_at', end.toUtc().toIso8601String())
          .order('created_at', ascending: true);

      final list = (res as List).map((e) => PrayerModel.fromJson(e)).toList();
      await LocalPrayerStore.writeCache(user.id, scope, list);
      _markOffline(ref, false);
      return list;
    } on PostgrestException {
      rethrow; // 서버 응답이 온 진짜 오류 — 오프라인 아님.
    } catch (_) {
      // 네트워크/소켓 예외 → 캐시 폴백.
      final cached = await LocalPrayerStore.readCache(user.id, scope);
      if (cached != null) {
        _markOffline(ref, true);
        return cached;
      }
      rethrow;
    }
  },
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<PrayerModel>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return [];

  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final res = await supabase
      .from('prayers')
      .select()
      .eq('user_id', user.id)
      .or('title.ilike.%$query%,content.ilike.%$query%')
      .order('created_at', ascending: false)
      .limit(20);

  return (res as List).map((e) => PrayerModel.fromJson(e)).toList();
});

// ── 기도 기록 탭 Provider ───────────────────────────────────────────────────────

enum StatsViewMode { month, week }

final statsViewModeProvider =
    StateProvider<StatsViewMode>((ref) => StatsViewMode.month);

final focusedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthPrayersProvider =
    FutureProvider.autoDispose.family<List<PrayerModel>, DateTime>(
  (ref, month) async {
    final supabase = ref.watch(supabaseProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1); // 다음 달 1일
    final scope = 'month:${start.toIso8601String()}';

    try {
      final res = await supabase
          .from('prayers')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', start.toUtc().toIso8601String())
          .lt('created_at', end.toUtc().toIso8601String())
          .order('created_at', ascending: true);

      final list = (res as List).map((e) => PrayerModel.fromJson(e)).toList();
      await LocalPrayerStore.writeCache(user.id, scope, list);
      _markOffline(ref, false);
      return list;
    } on PostgrestException {
      rethrow;
    } catch (_) {
      final cached = await LocalPrayerStore.readCache(user.id, scope);
      if (cached != null) {
        _markOffline(ref, true);
        return cached;
      }
      rethrow;
    }
  },
);

class PrayerStats {
  final Set<DateTime> writtenDays;
  final int streakCount;
  final int answeredCount;
  final int totalCount;

  const PrayerStats({
    required this.writtenDays,
    required this.streakCount,
    required this.answeredCount,
    required this.totalCount,
  });

  int get writtenDayCount => writtenDays.length;
}

DateTime _weekStart() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.subtract(Duration(days: today.weekday - 1)); // 월요일
}

PrayerStats _computeStats(List<PrayerModel> list, {bool weekOnly = false}) {
  List<PrayerModel> filtered = list;
  if (weekOnly) {
    final monday = _weekStart();
    final sunday = monday.add(const Duration(days: 6));
    filtered = list.where((p) {
      final d = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
      return !d.isBefore(monday) && !d.isAfter(sunday);
    }).toList();
  }

  final writtenDays = filtered.map((p) {
    final local = p.createdAt; // fromJson에서 이미 toLocal() 처리됨
    return DateTime(local.year, local.month, local.day);
  }).toSet();

  // 연속 기록: 오늘부터 거꾸로 (전체 월 데이터 기준, 주간 필터 미적용)
  var streak = 0;
  var check = DateTime.now();
  check = DateTime(check.year, check.month, check.day);
  final allDays = list.map((p) {
    final local = p.createdAt;
    return DateTime(local.year, local.month, local.day);
  }).toSet();
  while (allDays.contains(check)) {
    streak++;
    check = check.subtract(const Duration(days: 1));
  }

  return PrayerStats(
    writtenDays: writtenDays,
    streakCount: streak,
    answeredCount: filtered.where((p) => p.isAnswered).length,
    totalCount: filtered.length,
  );
}

final prayerStatsProvider =
    Provider.autoDispose<AsyncValue<PrayerStats>>((ref) {
  final month = ref.watch(focusedMonthProvider);
  final mode = ref.watch(statsViewModeProvider);
  final prayers = ref.watch(monthPrayersProvider(month));
  return prayers.whenData(
    (list) => _computeStats(list, weekOnly: mode == StatsViewMode.week),
  );
});

// 달력에 표시 중인 달(focusedMonth)의 최근 기록 10개.
// 달력·통계가 이미 불러온 monthPrayersProvider를 재사용하므로 추가 쿼리가 없다.
final recentPrayersProvider =
    Provider.autoDispose<AsyncValue<List<PrayerModel>>>((ref) {
  final month = ref.watch(focusedMonthProvider);
  final prayers = ref.watch(monthPrayersProvider(month));
  return prayers.whenData((list) {
    final sorted = [...list]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  });
});

final answeredTitlesProvider =
    Provider.autoDispose<AsyncValue<List<PrayerModel>>>((ref) {
  final month = ref.watch(focusedMonthProvider);
  final mode = ref.watch(statsViewModeProvider);
  final prayers = ref.watch(monthPrayersProvider(month));

  return prayers.whenData((list) {
    List<PrayerModel> filtered = list;
    if (mode == StatsViewMode.week) {
      final monday = _weekStart();
      final sunday = monday.add(const Duration(days: 6));
      filtered = list.where((p) {
        final d =
            DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
        return !d.isBefore(monday) && !d.isAfter(sunday);
      }).toList();
    }
    return filtered.where((p) => p.title.isNotEmpty).toList();
  });
});
