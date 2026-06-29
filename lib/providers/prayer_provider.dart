import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_model.dart';
import 'auth_provider.dart';

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

    final res = await supabase
        .from('prayers')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', start.toUtc().toIso8601String())
        .lt('created_at', end.toUtc().toIso8601String())
        .order('created_at', ascending: true);

    return (res as List).map((e) => PrayerModel.fromJson(e)).toList();
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

    final res = await supabase
        .from('prayers')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', start.toUtc().toIso8601String())
        .lt('created_at', end.toUtc().toIso8601String())
        .order('created_at', ascending: true);

    return (res as List).map((e) => PrayerModel.fromJson(e)).toList();
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

final recentPrayersProvider = FutureProvider.autoDispose<List<PrayerModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day).toUtc();
  final rangeStart = todayStart.subtract(const Duration(days: 60));

  final res = await supabase
      .from('prayers')
      .select()
      .eq('user_id', user.id)
      .lt('created_at', todayStart.toIso8601String())
      .gte('created_at', rangeStart.toIso8601String())
      .order('created_at', ascending: false)
      .limit(60);

  return (res as List).map((e) => PrayerModel.fromJson(e)).toList();
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
