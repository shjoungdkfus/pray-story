import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/nav_provider.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/month_titles_section.dart';
import 'widgets/prayer_calendar.dart';
import 'widgets/stats_summary_row.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(statsViewModeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '나의 기도 기록',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // 월간/주간 토글 pill
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F0E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _PillButton(
                      label: '월간',
                      isSelected: mode == StatsViewMode.month,
                      onTap: () {
                        ref.read(statsViewModeProvider.notifier).state =
                            StatsViewMode.month;
                        // 주간→월간 전환 시 현재 월로 리셋
                        final now = DateTime.now();
                        ref.read(focusedMonthProvider.notifier).state =
                            DateTime(now.year, now.month);
                      },
                    ),
                    _PillButton(
                      label: '주간',
                      isSelected: mode == StatsViewMode.week,
                      onTap: () {
                        ref.read(statsViewModeProvider.notifier).state =
                            StatsViewMode.week;
                        final now = DateTime.now();
                        ref.read(focusedMonthProvider.notifier).state =
                            DateTime(now.year, now.month);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // 통계 카드
            const StatsSummaryRow(),
            // 달력
            PrayerCalendar(
              onDayTap: (date) {
                ref.read(previousTabProvider.notifier).state = 1;
                ref.read(selectedDateProvider.notifier).state = date;
                ref.read(shellTabProvider.notifier).state = 0;
              },
            ),
            // 기도 제목 목록
            MonthTitlesSection(
              onTitleTap: (date) {
                ref.read(previousTabProvider.notifier).state = 1;
                ref.read(selectedDateProvider.notifier).state = date;
                ref.read(shellTabProvider.notifier).state = 0;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: AppColors.divider, width: 0.5)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.gowunBatang(
              fontSize: 13,
              color: isSelected ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}
