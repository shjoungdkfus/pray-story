import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/prayer_model.dart';
import '../../../providers/nav_provider.dart';
import '../../../providers/prayer_provider.dart';
import 'month_envelope_grid_widget.dart';

class MonthGridScreen extends ConsumerWidget {
  final DateTime month;

  const MonthGridScreen({super.key, required this.month});

  DayCellState _dayState(List<PrayerModel> prayers, int day, DateTime now) {
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
    final monthKey = DateTime(month.year, month.month);
    final prayersAsync = ref.watch(monthPrayersProvider(monthKey));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${month.year}년 ${month.month}월의 편지',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: prayersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Text(
            '오류가 발생했어요',
            style: GoogleFonts.gowunBatang(color: AppColors.textHint),
          ),
        ),
        data: (prayers) => Padding(
          padding: const EdgeInsets.all(20),
          child: MonthEnvelopeGridWidget(
            month: monthKey,
            dayState: (day) => _dayState(prayers, day, now),
            onDayTap: (day) {
              final date = DateTime(month.year, month.month, day);
              ref.read(previousTabProvider.notifier).state = 1;
              ref.read(selectedDateProvider.notifier).state = date;
              ref.read(shellTabProvider.notifier).state = 0;
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
