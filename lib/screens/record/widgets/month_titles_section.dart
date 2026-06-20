import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/prayer_model.dart';
import '../../../providers/prayer_provider.dart';

class MonthTitlesSection extends ConsumerWidget {
  final void Function(DateTime) onTitleTap;

  const MonthTitlesSection({super.key, required this.onTitleTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesAsync = ref.watch(answeredTitlesProvider);

    return titlesAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
                  '기도 제목',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                for (var i = 0; i < list.length; i++) ...[
                  _TitleRow(
                    prayer: list[i],
                    onTap: () => onTitleTap(_dateOnly(list[i].createdAt)),
                  ),
                  if (i < list.length - 1)
                    Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.4)),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class _TitleRow extends StatelessWidget {
  final PrayerModel prayer;
  final VoidCallback onTap;

  const _TitleRow({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = prayer.createdAt;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              '${date.month}/${date.day}',
              style: GoogleFonts.gowunBatang(fontSize: 11, color: AppColors.textHint),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                prayer.title,
                style: GoogleFonts.gowunBatang(fontSize: 14, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
