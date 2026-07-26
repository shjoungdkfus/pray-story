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
    // 종전엔 error 분기가 없어 조회 실패도 "0일 / 0회"로 표시돼 실패와 진짜 0건을
    // 구분할 수 없었다(PS-UI-09). 캐시된 값도 없이 실패했으면 숫자 대신 '—'를 쓴다.
    final failed = statsAsync.hasError && stats == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: [
          _StatCard(
            value: stats?.writtenDayCount ?? 0,
            unit: l.statUnitDays,
            subtitle: l.statThisMonth,
            unavailable: failed,
            unavailableLabel: l.statsUnavailable,
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: stats?.answeredCount ?? 0,
            unit: l.statUnitCount,
            subtitle: l.statAnswered,
            unavailable: failed,
            unavailableLabel: l.statsUnavailable,
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

  /// 조회 실패로 숫자를 신뢰할 수 없을 때 true — 0 대신 대체 문자를 보여준다.
  final bool unavailable;
  final String unavailableLabel;

  const _StatCard({
    required this.value,
    required this.unit,
    required this.subtitle,
    this.unavailable = false,
    this.unavailableLabel = '—',
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
                    text: unavailable ? unavailableLabel : '$value',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: unavailable
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (!unavailable)
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
