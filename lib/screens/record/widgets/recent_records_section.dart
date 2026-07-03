import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/prayer_model.dart';
import '../../../providers/prayer_provider.dart';

class RecentRecordsSection extends ConsumerWidget {
  final void Function(DateTime) onTap;

  const RecentRecordsSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recentAsync = ref.watch(recentPrayersProvider);

    return recentAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        child: Text(l.recordLoadError(e),
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.recordRecent,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                for (var i = 0; i < list.length; i++) ...[
                  _RecordRow(
                    prayer: list[i],
                    onTap: () {
                      final d = list[i].createdAt;
                      onTap(DateTime(d.year, d.month, d.day));
                    },
                  ),
                  if (i < list.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.divider.withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecordRow extends StatelessWidget {
  final PrayerModel prayer;
  final VoidCallback onTap;

  const _RecordRow({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final date = prayer.createdAt;
    final dateLabel = DateFormat.MMMEd(locale).format(date);
    final hasTitle = prayer.title.trim().isNotEmpty;
    final title = hasTitle ? prayer.title.trim() : l.recordUntitled;
    // 본문 미리보기: 첫 줄만
    final preview = prayer.content.trim().split('\n').first.trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 줄 (+ 응답 체크)
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasTitle
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontStyle:
                          hasTitle ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (prayer.isAnswered) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle_outline,
                    size: 13,
                    color: AppColors.accent.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
            // 본문 미리보기 (있을 때만)
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                preview,
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // 날짜
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                color: AppColors.textHint.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
