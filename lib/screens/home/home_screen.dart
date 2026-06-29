import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/font_size_picker_sheet.dart';
import '../write/prayer_write_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final profile = ref.watch(profileProvider);
    final displayName = profile.valueOrNull?.name.isNotEmpty == true
        ? profile.valueOrNull!.name
        : (ref.watch(currentUserProvider)?.email?.split('@').first ?? '나');

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    isToday
                        ? DateFormat('M월 d일 EEEE', 'ko').format(date)
                        : DateFormat('yyyy년 M월 d일 (E)', 'ko').format(date),
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isToday)
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(selectedDateProvider.notifier)
                            .state = DateTime.now(),
                        child: Text(
                          '오늘로',
                          style: GoogleFonts.gowunBatang(
                            color: AppColors.accent,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF9F4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isToday) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 4),
                              child: Center(
                                child: Text(
                                  '$displayName의 이야기',
                                  style: GoogleFonts.gowunBatang(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: AppColors.divider.withValues(alpha: 0.6),
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                          ] else
                            const SizedBox(height: 20),
                          _SelectedDatePrayers(date: date),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 오늘 날짜 기도 목록 ────────────────────────────────────────────────────────

class _SelectedDatePrayers extends ConsumerWidget {
  final DateTime date;
  const _SelectedDatePrayers({required this.date});

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
          child: PrayerWriteScreen(targetDate: date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayersForDateProvider(date));

    return prayers.when(
      loading: () => const SizedBox(height: 80),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          return GestureDetector(
            onTap: () => _openWriteSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  _isToday
                      ? '오늘 하루, 당신의 삶에\n행하신 하나님의 이야기를\n기록해 보세요.'
                      : '이 날의 이야기를\n기록해 보세요.',
                  style: GoogleFonts.gowunBatang(
                    color: AppColors.textHint,
                    fontSize: 13,
                    height: 1.9,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < list.length; i++) ...[
              if (i > 0) const _EntryDivider(),
              _PrayerEntry(prayer: list[i]),
            ],
            GestureDetector(
              onTap: () => _openWriteSheet(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 40, width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

// ── 기도 항목 (전체 표시, 밑줄 포함) ──────────────────────────────────────────

class _EntryDivider extends StatelessWidget {
  const _EntryDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.55),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Transform.rotate(
              angle: 0.7853981633974483,
              child: Container(
                width: 6,
                height: 6,
                color: AppColors.accent.withValues(alpha: 0.55),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
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

  String _timeLabel() {
    if (PrayerModel.isDateOnly(prayer.createdAt)) return '';
    final diff = DateTime.now().difference(prayer.createdAt);
    if (!diff.isNegative && diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m <= 0 ? '방금 전' : '$m분 전';
    }
    return DateFormat('a h시 m분', 'ko').format(prayer.createdAt);
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
    final time = _timeLabel();
    final hasTitle = prayer.title.isNotEmpty;

    return GestureDetector(
      onTap: () => _openEditSheet(context),
      onLongPress: () => _showDeleteDialog(context, ref),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle || time.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (hasTitle)
                  Flexible(
                    child: Text(
                      prayer.title,
                      style: GoogleFonts.gowunBatang(
                        color: AppColors.accent,
                        fontSize: fontSize + 3,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (hasTitle && time.isNotEmpty) const SizedBox(width: 8),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textHint.withValues(alpha: 0.8),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
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
        ],
      ),
    );
  }
}
