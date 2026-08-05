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
import '../../widgets/error_retry_view.dart';
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
    final isOffline = ref.watch(isOfflineProvider);
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
                            color: AppColors.accentText,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accentText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isOffline) _OfflineBanner(l: l),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.75, 0.75, 12.75, 12.75),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
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

// ── 오프라인 배지 (B3): 네트워크 실패로 캐시된 내용을 보여줄 때 표시 ──

class _OfflineBanner extends StatelessWidget {
  final AppLocalizations l;
  const _OfflineBanner({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12.75, 0, 12.75, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 15, color: AppColors.textHint),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l.offlineCachedNotice,
              style: GoogleFonts.notoSansKr(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
      // 종전엔 loading·error 둘 다 SizedBox.shrink()라 서버 오류 시 안내도 재시도도 없는
      // 완전한 빈 카드가 됐다(PS-UI-03). 로딩은 스피너, 에러는 재시도 뷰로 명시한다.
      loading: () => Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accentText,
          ),
        ),
      ),
      error: (e, _) {
        debugPrint('prayersForDateProvider failed: $e');
        return ErrorRetryView(
          onRetry: () => ref.invalidate(prayersForDateProvider(date)),
        );
      },
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
                        color: AppColors.textPrimary,
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
                color: AppColors.accentText.withValues(alpha: 0.55),
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
      // 폭(width) 임계값만으로는 실기기에서 일부 빈 줄이 걸러지지 않는
      // 사례가 보고됐다(PS-UI-22). 레이아웃 결과(width) 대신 원본 문자열을
      // 직접 조회해 판정한다 — getLineBoundary는 줄바꿈으로 인한 자동
      // 개행까지 정확히 반영하므로 `text.split('\n')` 인덱스 매칭보다
      // 안전하다(긴 줄이 자동 줄바꿈되는 경우에도 어긋나지 않음).
      final probeY = metric.baseline - metric.ascent / 2;
      final probe = tp.getPositionForOffset(Offset(metric.left + 1.0, probeY));
      final range = tp.getLineBoundary(probe);
      final lineText = text.substring(range.start, range.end);
      if (lineText.trim().isEmpty) continue;

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

    // 삭제 후 목록이 rebuild되며 이 항목(context/ref)이 폐기될 수 있으니 미리 캡처.
    final deleted = prayer;
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('prayers').delete().eq('id', deleted.id);
      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);
      showPrayerDeletedSnackBar(
        messenger: messenger,
        container: container,
        l: l,
        deleted: deleted,
      );
    } catch (_) {
      messenger.showSnackBar(
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
                        color: AppColors.textPrimary,
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
