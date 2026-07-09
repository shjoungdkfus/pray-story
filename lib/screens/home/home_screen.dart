import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final date = ref.watch(selectedDateProvider);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final profile = ref.watch(profileProvider);
    final displayName = profile.valueOrNull?.name.isNotEmpty == true
        ? profile.valueOrNull!.name
        : (ref.watch(currentUserProvider)?.email?.split('@').first ??
            l.homeDefaultName);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showFontSizePicker(context),
        backgroundColor: AppColors.card,
        elevation: 2,
        child: Icon(
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
                        ? DateFormat.MMMMEEEEd(locale).format(date)
                        : DateFormat.yMMMEd(locale).format(date),
                    style: GoogleFonts.notoSansKr(
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
                          l.homeToToday,
                          style: GoogleFonts.notoSansKr(
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
                padding: const EdgeInsets.fromLTRB(12.75, 0.75, 12.75, 12.75),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.isDark
                        ? const Color(0xFFF0DCC8)
                        : const Color(0xFFF8F4EC),
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
                    child: _BookPage(
                      date: date,
                      isToday: isToday,
                      displayName: displayName,
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

// ── 페이지 본문 (빈 상태: 전체 영역 탭 가능 + 중앙 안내문 / 내용 있을 때: 스크롤) ──

class _BookPage extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final String displayName;

  const _BookPage({
    required this.date,
    required this.isToday,
    required this.displayName,
  });

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

  Widget _buildDayHeader(AppLocalizations l) {
    if (!isToday) return const SizedBox(height: 20);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Center(
            child: Text(
              l.homeStoryOf(displayName),
              style: GoogleFonts.notoSansKr(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prayers = ref.watch(prayersForDateProvider(date));

    return prayers.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          // 빈 페이지: 전체 영역이 탭 가능 + 안내문 수직 중앙
          return GestureDetector(
            onTap: () => _openWriteSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: _buildDayHeader(l),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      isToday ? l.homeEmptyToday : l.homeEmptyOther,
                      style: GoogleFonts.notoSansKr(
                        color: AppColors.textHint,
                        fontSize: 13,
                        height: 1.9,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 내용 있을 때: 전체 페이지 영역이 탭 가능 (빈 공간 탭 → 새 글 쓰기)
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: GestureDetector(
                  onTap: () => _openWriteSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDayHeader(l),
                        for (int i = 0; i < list.length; i++) ...[
                          if (i > 0) const _EntryDivider(),
                          _PrayerEntry(prayer: list[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

  String _timeLabel(AppLocalizations l, String locale) {
    if (PrayerModel.isDateOnly(prayer.createdAt)) return '';
    final diff = DateTime.now().difference(prayer.createdAt);
    if (!diff.isNegative && diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m <= 0 ? l.timeJustNow : l.timeMinutesAgo(m);
    }
    return DateFormat.jm(locale).format(prayer.createdAt);
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
    final l = AppLocalizations.of(context);
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
          content: Text(l.recordDeleted, style: GoogleFonts.notoSansKr()),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final fontSize = ref.watch(fontSizeProvider);
    final time = _timeLabel(l, locale);
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
                      style: GoogleFonts.notoSansKr(
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
                    style: GoogleFonts.notoSansKr(
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
            style: GoogleFonts.notoSansKr(
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
