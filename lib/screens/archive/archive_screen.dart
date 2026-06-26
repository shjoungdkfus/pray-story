import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_model.dart';
import '../../providers/nav_provider.dart';
import '../../providers/prayer_provider.dart';
import 'widgets/book_spine_painter.dart';
import 'widgets/cta_card_widget.dart';
import 'widgets/month_envelope_grid_widget.dart';
import 'widgets/month_grid_screen.dart';
import 'widgets/yearly_bookshelf_widget.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  List<BookMonthData> _buildMonthData(List<PrayerModel> prayers, DateTime now) {
    return List.generate(12, (i) {
      final monthNum = i + 1;
      final month = DateTime(now.year, monthNum);

      final writtenDays = prayers
          .where((p) => p.createdAt.month == monthNum)
          .map((p) => p.createdAt.day)
          .toSet();

      final BookSpineState state;
      if (monthNum < now.month) {
        state = BookSpineState.completed;
      } else if (monthNum == now.month) {
        state = BookSpineState.current;
      } else {
        state = BookSpineState.future;
      }

      return BookMonthData(month: month, letterCount: writtenDays.length, state: state);
    });
  }

  DayCellState _dayState(List<PrayerModel> prayers, int day, DateTime now, DateTime month) {
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    if (isCurrentMonth && day == now.day) return DayCellState.today;
    if (isCurrentMonth && day > now.day) return DayCellState.futureDisabled;

    final dayPrayers = prayers.where((p) => p.createdAt.day == day).toList();
    if (dayPrayers.isEmpty) return DayCellState.emptyPast;
    if (dayPrayers.any((p) => p.isAnswered)) return DayCellState.answered;
    return DayCellState.written;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final yearAsync = ref.watch(yearPrayersProvider(now.year));
    final currentMonth = DateTime(now.year, now.month);
    final currentMonthAsync = ref.watch(monthPrayersProvider(currentMonth));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: yearAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(
            child: Text(
              '오류가 발생했어요',
              style: GoogleFonts.gowunBatang(color: AppColors.textHint),
            ),
          ),
          data: (yearPrayers) {
            final months = _buildMonthData(yearPrayers, now);
            final totalDays = yearPrayers
                .map((p) => '${p.createdAt.year}-${p.createdAt.month}-${p.createdAt.day}')
                .toSet()
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나의 서신함',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalDays > 0 ? '올해 $totalDays일의 편지가 모였어요' : '첫 번째 편지를 써보세요',
                    style: GoogleFonts.gowunBatang(fontSize: 13, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 20),
                  YearlyBookshelfWidget(
                    months: months,
                    onMonthTap: (data) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MonthGridScreen(month: data.month),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '${now.month}월의 편지',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  currentMonthAsync.when(
                    loading: () => const SizedBox(
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (monthPrayers) => MonthEnvelopeGridWidget(
                      month: currentMonth,
                      dayState: (day) => _dayState(monthPrayers, day, now, currentMonth),
                      onDayTap: (day) {
                        final date = DateTime(now.year, now.month, day);
                        ref.read(previousTabProvider.notifier).state = 1;
                        ref.read(selectedDateProvider.notifier).state = date;
                        ref.read(shellTabProvider.notifier).state = 0;
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  currentMonthAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (monthPrayers) {
                      final isWrittenToday = monthPrayers.any((p) {
                        final d = p.createdAt;
                        return d.year == now.year &&
                            d.month == now.month &&
                            d.day == now.day;
                      });
                      return CtaCardWidget(
                        isWrittenToday: isWrittenToday,
                        onWriteTap: () =>
                            ref.read(shellTabProvider.notifier).state = 0,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
