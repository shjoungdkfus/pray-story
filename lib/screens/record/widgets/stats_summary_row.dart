import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/prayer_provider.dart';

class StatsSummaryRow extends ConsumerStatefulWidget {
  const StatsSummaryRow({super.key});

  @override
  ConsumerState<StatsSummaryRow> createState() => _StatsSummaryRowState();
}

class _StatsSummaryRowState extends ConsumerState<StatsSummaryRow> {
  PrayerStats? _lastStats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statsAsync = ref.watch(prayerStatsProvider);

    // 새 데이터가 도착하면 즉시 캐시 — setState 불필요 (같은 build 프레임에서 반영)
    final incoming = statsAsync.whenOrNull(data: (s) => s);
    if (incoming != null) _lastStats = incoming;

    final stats = _lastStats;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: [
          _StatCard(
            value: stats?.writtenDayCount ?? 0,
            unit: l.statUnitDays,
            subtitle: l.statThisMonth,
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: stats?.answeredCount ?? 0,
            unit: l.statUnitCount,
            subtitle: l.statAnswered,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int value;
  final String unit;
  final String subtitle;

  const _StatCard({
    required this.value,
    required this.unit,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  TextSpan(
                    text: unit,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
