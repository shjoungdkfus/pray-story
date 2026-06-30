import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/prayer_provider.dart';

class PrayerCalendar extends ConsumerWidget {
  final void Function(DateTime) onDayTap;

  const PrayerCalendar({super.key, required this.onDayTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(statsViewModeProvider);
    return mode == StatsViewMode.month
        ? _MonthCalendar(onDayTap: onDayTap)
        : _WeekCalendar(onDayTap: onDayTap);
  }
}

// ── 월간 달력 (PageView 슬라이딩) ──────────────────────────────────────────────

class _MonthCalendar extends ConsumerStatefulWidget {
  final void Function(DateTime) onDayTap;
  const _MonthCalendar({required this.onDayTap});

  @override
  ConsumerState<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends ConsumerState<_MonthCalendar> {
  // 현재 달 = page 1200, 과거로 최대 1200달 이동 가능
  static const _kInitialPage = 1200;
  static final _kBaseMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  late final PageController _pageController;
  bool _programmatic = false; // 화살표 버튼 → PageView 동기화 중 플래그

  DateTime _monthForPage(int page) {
    final diff = page - _kInitialPage;
    return DateTime(_kBaseMonth.year, _kBaseMonth.month + diff);
  }

  int _pageForMonth(DateTime month) {
    return _kInitialPage +
        (month.year - _kBaseMonth.year) * 12 +
        (month.month - _kBaseMonth.month);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _kInitialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusedMonth = ref.watch(focusedMonthProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonth = DateTime(now.year, now.month);
    final isCurrentMonth = focusedMonth == currentMonth;

    // 화살표 버튼으로 focusedMonth가 바뀌면 PageView도 슬라이드
    ref.listen<DateTime>(focusedMonthProvider, (prev, next) {
      if (_programmatic) return;
      final targetPage = _pageForMonth(next);
      if (!_pageController.hasClients) return;
      if (_pageController.page?.round() == targetPage) return;
      _programmatic = true;
      _pageController
          .animateToPage(targetPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut)
          .then((_) => _programmatic = false);
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          children: [
            // 월 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.chevron_left,
                      size: 20, color: AppColors.textPrimary),
                  onPressed: () {
                    ref.read(focusedMonthProvider.notifier).state =
                        DateTime(focusedMonth.year, focusedMonth.month - 1);
                  },
                ),
                Text(
                  '${focusedMonth.year}년 ${focusedMonth.month}월',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isCurrentMonth
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                  onPressed: isCurrentMonth
                      ? null
                      : () {
                          ref.read(focusedMonthProvider.notifier).state =
                              DateTime(
                                  focusedMonth.year, focusedMonth.month + 1);
                        },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 요일 헤더 (일~토)
            Row(
              children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.gowunBatang(
                        fontSize: 10, color: AppColors.textHint),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            // PageView: 최대 6행 높이 고정, 슬라이드로 월 이동
            LayoutBuilder(builder: (context, constraints) {
              final cellSize = constraints.maxWidth / 7;
              // 최대 6행 + 행간 spacing(2) × 5
              final gridHeight = cellSize * 6 + 5 * 2;
              return SizedBox(
                height: gridHeight,
                child: PageView.builder(
                  controller: _pageController,
                  // 미래 달 이동 차단 (itemCount = initialPage + 1)
                  itemCount: _kInitialPage + 1,
                  onPageChanged: (page) {
                    if (_programmatic) return;
                    final month = _monthForPage(page);
                    ref.read(focusedMonthProvider.notifier).state = month;
                  },
                  itemBuilder: (context, page) {
                    final month = _monthForPage(page);
                    return _CalendarGrid(
                      key: ValueKey(month),
                      month: month,
                      today: today,
                      onDayTap: widget.onDayTap,
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── 한 달 그리드 ─────────────────────────────────────────────────────────────

class _CalendarGrid extends ConsumerWidget {
  final DateTime month;
  final DateTime today;
  final void Function(DateTime) onDayTap;

  const _CalendarGrid({
    super.key,
    required this.month,
    required this.today,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 각 페이지가 자신의 달 데이터를 직접 구독
    final prayersAsync = ref.watch(monthPrayersProvider(month));
    final writtenDays = prayersAsync.whenOrNull(
          data: (list) => list.map((p) {
            final local = p.createdAt;
            return DateTime(local.year, local.month, local.day);
          }).toSet(),
        ) ??
        {};

    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7; // 일=0, 월=1, ..., 토=6
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 0,
      ),
      itemCount: startOffset + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox.shrink();
        final day = index - startOffset + 1;
        final date = DateTime(month.year, month.month, day);
        return _DayCell(
          day: day,
          date: date,
          today: today,
          isWritten: writtenDays.contains(date),
          isFuture: date.isAfter(today),
          onTap: () => onDayTap(date),
        );
      },
    );
  }
}

// ── 주간 달력 ─────────────────────────────────────────────────────────────────

class _WeekCalendar extends ConsumerWidget {
  final void Function(DateTime) onDayTap;
  const _WeekCalendar({required this.onDayTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(prayerStatsProvider);
    final writtenDays =
        statsAsync.whenOrNull(data: (s) => s.writtenDays) ?? {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final weekNum = ((monday.day - 1) ~/ 7) + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              '${monday.year}년 ${monday.month}월 $weekNum주차',
              style: GoogleFonts.gowunBatang(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['월', '화', '수', '목', '금', '토', '일'].map((d) {
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.gowunBatang(
                        fontSize: 10, color: AppColors.textHint),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Row(
              children: weekDays.map((date) {
                return Expanded(
                  child: _DayCell(
                    day: date.day,
                    date: date,
                    today: today,
                    isWritten: writtenDays.contains(date),
                    isFuture: date.isAfter(today),
                    onTap: () => onDayTap(date),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 날짜 셀 ───────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final DateTime today;
  final bool isWritten;
  final bool isFuture;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.date,
    required this.today,
    required this.isWritten,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = date == today;

    final textColor =
        isFuture ? const Color(0xFFAA9880) : AppColors.textPrimary;

    Widget cell;
    if (isWritten) {
      cell = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: GoogleFonts.gowunBatang(
              fontSize: 13, color: AppColors.background),
        ),
      );
    } else if (isToday) {
      cell = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style:
              GoogleFonts.gowunBatang(fontSize: 13, color: textColor),
        ),
      );
    } else {
      cell = SizedBox(
        width: 26,
        height: 26,
        child: Center(
          child: Text(
            '$day',
            style:
                GoogleFonts.gowunBatang(fontSize: 13, color: textColor),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(child: cell),
      ),
    );
  }
}
