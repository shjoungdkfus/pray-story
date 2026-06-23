import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/font_size_picker_sheet.dart';
import '../../widgets/notification_picker_sheet.dart';
import '../write/prayer_write_screen.dart';
import 'history_search_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;

  static final _baseDate = DateTime(2020, 1, 1);

  static int _dateToPage(DateTime date) =>
      DateTime(date.year, date.month, date.day).difference(_baseDate).inDays;

  static DateTime _pageToDate(int page) {
    final d = _baseDate.add(Duration(days: page));
    return DateTime(d.year, d.month, d.day);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _dateToPage(DateTime.now()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFontSizePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const FontSizePickerSheet(),
    );
  }

  void _showDatePicker(BuildContext context) {
    var picked = ref.read(selectedDateProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '취소',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textHint,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '날짜 이동',
                  style: GoogleFonts.gowunBatang(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _dateToPage(picked),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    '확인',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: picked,
              maximumDate: DateTime.now(),
              minimumDate: DateTime(2020),
              backgroundColor: AppColors.card,
              onDateTimeChanged: (d) => picked = d,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);

    ref.listen<DateTime>(selectedDateProvider, (_, next) {
      if (!_pageController.hasClients) return;
      final target = _dateToPage(next);
      if (_pageController.page?.round() != target) {
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    final profile = ref.watch(profileProvider);

    final displayName = profile.valueOrNull?.name.isNotEmpty == true
        ? profile.valueOrNull!.name
        : (ref.watch(currentUserProvider)?.email?.split('@').first ?? '나');
    final todayPage = _dateToPage(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showFontSizePicker(context),
        backgroundColor: AppColors.card,
        elevation: 2,
        child: const Icon(
          Icons.format_size,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
      floatingActionButtonLocation: const _SearchBarFabLocation(),
      body: SafeArea(
        child: Column(
          children: [
            _DateNavigationBar(
              date: date,
              onPrev: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              ),
              onNext: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              ),
              onDateTap: () => _showDatePicker(context),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const PageScrollPhysics(),
                onPageChanged: (page) {
                  ref.read(selectedDateProvider.notifier).state =
                      _pageToDate(page);
                },
                itemCount: todayPage + 1,
                itemBuilder: (_, page) {
                  final pageDate = _pageToDate(page);
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double offset = 0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        offset = (_pageController.page! - page)
                            .abs()
                            .clamp(0.0, 1.0);
                      }
                      return Opacity(
                        opacity: (1.0 - offset * 0.35).clamp(0.65, 1.0),
                        child: Transform.scale(
                          scale: (1.0 - offset * 0.04).clamp(0.96, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: _BookContainer(
                        title: '$displayName의 이야기',
                        child: _BookPage(date: pageDate),
                      ),
                    ),
                  );
                },
              ),
            ),
            _PrewarmWidget(currentDate: date),
            const HistorySearchOverlay(),
          ],
        ),
      ),
    );
  }
}

class _DateNavigationBar extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onDateTap;

  const _DateNavigationBar({
    required this.date,
    required this.onPrev,
    required this.onNext,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: onPrev,
          ),
          GestureDetector(
            onTap: onDateTap,
            child: Text(
              DateFormat('yyyy년 M월 d일 (E)', 'ko').format(date),
              style: GoogleFonts.gowunBatang(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isToday ? AppColors.textHint : AppColors.textPrimary,
            ),
            onPressed: isToday ? null : onNext,
          ),
        ],
      ),
    );
  }
}

class _BookContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _BookContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EA),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSpine(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSpine() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.gowunBatang(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BookPage extends ConsumerStatefulWidget {
  final DateTime date;

  _BookPage({required this.date}) : super(key: ValueKey(date));

  @override
  ConsumerState<_BookPage> createState() => _BookPageState();
}

class _BookPageState extends ConsumerState<_BookPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool get _isToday {
    final now = DateTime.now();
    return widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
  }

  void _openWriteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: PrayerWriteScreen(targetDate: widget.date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final prayers = ref.watch(prayersForDateProvider(widget.date));
    return prayers.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(
        child: Text(
          '기록을 불러오는 중\n문제가 발생했습니다.',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return GestureDetector(
            onTap: () => _openWriteSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Text(
                _isToday
                    ? '오늘 하루, 당신의 삶에\n행하신 하나님의 이야기를\n기록해 보세요.'
                    : '지난 날의 이야기를\n기록해 보세요.',
                style: GoogleFonts.gowunBatang(
                  color: AppColors.textHint,
                  fontSize: 13,
                  height: 1.9,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 글이 있을 때: 항목 탭 → 수정, 항목 아래 빈 공간 탭 → 새 글
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const Divider(
                        color: AppColors.divider,
                        height: 32,
                        thickness: 1.0,
                      );
                    }
                    return _PrayerEntry(prayer: list[index ~/ 2]);
                  },
                  childCount: list.length * 2 - 1,
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: GestureDetector(
                onTap: () => _openWriteSheet(context),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 현재 날짜 ±2일 데이터를 미리 fetch해 스와이프 전에 준비
class _PrewarmWidget extends ConsumerWidget {
  final DateTime currentDate;
  const _PrewarmWidget({required this.currentDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    for (int i = 1; i <= 2; i++) {
      ref.watch(prayersForDateProvider(currentDate.subtract(Duration(days: i))));
      final next = currentDate.add(Duration(days: i));
      if (!next.isAfter(today)) {
        ref.watch(prayersForDateProvider(next));
      }
    }
    return const SizedBox.shrink();
  }
}

class _UnderlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _UnderlinedText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _UnderlinePainter(
            text: text,
            style: style,
            maxWidth: constraints.maxWidth,
          ),
          child: Text(text, style: style),
        );
      },
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double maxWidth;

  _UnderlinePainter({
    required this.text,
    required this.style,
    required this.maxWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final strokeWidth = (style.fontSize ?? 12.0) / 12.0;
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.7)
      ..strokeWidth = strokeWidth;

    final heightMul = style.height ?? 1.0;
    final fSize = style.fontSize ?? 14.0;
    final extraBelow = (heightMul - 1.0) * fSize / 2.0;

    for (final metric in tp.computeLineMetrics()) {
      if (metric.width < 1.0) continue;
      final y = metric.baseline + metric.descent - extraBelow - 2.0;
      canvas.drawLine(
        Offset(metric.left, y),
        Offset(metric.left + metric.width, y),
        paint,
      );
    }

    tp.dispose();
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) =>
      old.text != text || old.style != style || old.maxWidth != maxWidth;
}

class _PrayerEntry extends ConsumerWidget {
  final PrayerModel prayer;
  const _PrayerEntry({required this.prayer});

  // 정오(12:00:00.000)로 저장된 과거 날짜 기록은 시간 정보가 없음
  bool _isDateOnly(DateTime dt) =>
      dt.hour == 12 && dt.minute == 0 && dt.second == 0 && dt.millisecond == 0;

  String _formatTimestamp(PrayerModel p) {
    final hasUpdated = p.updatedAt != null &&
        p.updatedAt!.difference(p.createdAt).abs().inMinutes >= 1;

    if (_isDateOnly(p.createdAt)) {
      if (!hasUpdated) return '';
      return '수정 ${DateFormat('a h:mm', 'ko').format(p.updatedAt!)}';
    }

    final created = DateFormat('a h:mm', 'ko').format(p.createdAt);
    if (!hasUpdated) return created;

    final isSameDay = DateUtils.isSameDay(p.createdAt, p.updatedAt!);
    final editStr = isSameDay
        ? DateFormat('a h:mm', 'ko').format(p.updatedAt!)
        : DateFormat('M.d').format(p.updatedAt!);
    return '$created  ·  수정 $editStr';
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: PrayerWriteScreen(prayer: prayer),
        ),
      ),
    );
  }

  Future<void> _setAlarm(BuildContext context, WidgetRef ref, List<DateTime> current) async {
    await NotificationService.requestPermission();
    if (!context.mounted) return;
    final picked = await showNotificationPickerSheet(context, initial: current);
    if (picked == null) return;
    await ref.read(tomorrowAlarmsProvider.notifier).addTomorrowAlarm(
          prayerId: prayer.id,
          title: prayer.title,
          content: prayer.content,
          alarmTimes: picked,
        );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteConfirmDialog(context);
    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('prayers').delete().eq('id', prayer.id);
      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기록이 삭제되었습니다.', style: GoogleFonts.gowunBatang()),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 중 문제가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final alarms = ref.watch(tomorrowAlarmsProvider);
    final activeAlarms = alarms.where((a) => a.prayerId == prayer.id && a.enabled).toList()
      ..sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    return GestureDetector(
      onTap: () => _openEditSheet(context),
      onLongPress: () => _showDeleteDialog(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prayer.title.isNotEmpty) ...[
            _UnderlinedText(
              text: prayer.title,
              style: GoogleFonts.gowunBatang(
                color: AppColors.accent,
                fontSize: fontSize + 3,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
          ],
          _UnderlinedText(
            text: prayer.content,
            style: GoogleFonts.gowunBatang(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              height: 2.2,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _formatTimestamp(prayer).isEmpty
                      ? null
                      : Text(
                          _formatTimestamp(prayer),
                          style: GoogleFonts.gowunBatang(
                            color: AppColors.textHint.withValues(alpha: 0.7),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _setAlarm(context, ref, activeAlarms.map((a) => a.alarmTime).toList()),
                onLongPress: activeAlarms.isEmpty
                    ? null
                    : () => ref.read(tomorrowAlarmsProvider.notifier).cancelAlarm(prayer.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: activeAlarms.isNotEmpty
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        activeAlarms.isNotEmpty
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        size: 18,
                        color: activeAlarms.isNotEmpty ? Colors.white : AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activeAlarms.isEmpty
                            ? '알림'
                            : activeAlarms.length == 1
                                ? DateFormat('M.d a h:mm', 'ko').format(activeAlarms.first.alarmTime)
                                : '${activeAlarms.length}개 알림',
                        style: GoogleFonts.gowunBatang(
                          color: activeAlarms.isNotEmpty ? Colors.white : AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBarFabLocation extends FloatingActionButtonLocation {
  const _SearchBarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final x = scaffoldGeometry.scaffoldSize.width
        - scaffoldGeometry.minInsets.right
        - 16
        - fabSize.width;
    final y = scaffoldGeometry.scaffoldSize.height
        - scaffoldGeometry.minInsets.bottom
        - 80
        - fabSize.height;
    return Offset(x, y);
  }
}
