import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/nav_provider.dart';
import '../../providers/prayer_provider.dart';
import '../home/history_search_overlay.dart';
import 'widgets/prayer_calendar.dart';
import 'widgets/recent_records_section.dart';
import 'widgets/stats_summary_row.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  void _goToDate(WidgetRef ref, DateTime date) {
    ref.read(previousTabProvider.notifier).state = 1;
    ref.read(selectedDateProvider.notifier).state = date;
    ref.read(shellTabProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Center(
                      child: Text(
                        '나의 기도 기록',
                        style: GoogleFonts.gowunBatang(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // 통계 카드 (이번 달 기록 / 응답 기록)
                  const StatsSummaryRow(),
                  // 달력 (월간)
                  PrayerCalendar(
                    onDayTap: (date) => _goToDate(ref, date),
                  ),
                  // 지난 기록 제목 목록
                  RecentRecordsSection(
                    onTap: (date) => _goToDate(ref, date),
                  ),
                ],
              ),
            ),
          ),
          // 맨 아래 통합 검색
          const HistorySearchOverlay(),
        ],
      ),
    );
  }
}
