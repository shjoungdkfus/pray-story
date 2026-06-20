import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
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
    final statsAsync = ref.watch(prayerStatsProvider);
    final mode = ref.watch(statsViewModeProvider);

    // 새 데이터가 도착하면 즉시 캐시 — setState 불필요 (같은 build 프레임에서 반영)
    final incoming = statsAsync.whenOrNull(data: (s) => s);
    if (incoming != null) _lastStats = incoming;

    final stats = _lastStats;
    String label;
    if (mode == StatsViewMode.month) {
      label = '이번 달 기록';
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final weekNum = ((monday.day - 1) ~/ 7) + 1;
      label = '${monday.month}월 $weekNum주차';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: [
          _StatCard(
            value: stats?.writtenDayCount ?? 0,
            unit: '일',
            subtitle: label,
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: stats?.streakCount ?? 0,
            unit: '일',
            subtitle: '연속 기록',
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
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  TextSpan(
                    text: unit,
                    style: GoogleFonts.gowunBatang(
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
              style: GoogleFonts.gowunBatang(
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
