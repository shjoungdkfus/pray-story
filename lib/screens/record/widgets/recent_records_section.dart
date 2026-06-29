import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/prayer_model.dart';
import '../../../providers/prayer_provider.dart';

class RecentRecordsSection extends ConsumerWidget {
  final void Function(DateTime) onTap;

  const RecentRecordsSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentPrayersProvider);

    return recentAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        child: Text('오류: $e', style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지난 기록',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
    final date = prayer.createdAt;
    final dateLabel = DateFormat('M/d', 'ko').format(date);
    final title = prayer.title.isNotEmpty ? prayer.title : prayer.content;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              dateLabel,
              style: GoogleFonts.gowunBatang(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.gowunBatang(
                  fontSize: 14,
                  color: AppColors.textPrimary,
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
      ),
    );
  }
}
