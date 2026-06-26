import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

enum DayCellState { written, answered, emptyPast, today, futureDisabled }

class MonthEnvelopeGridWidget extends StatelessWidget {
  final DateTime month;
  final DayCellState Function(int day) dayState;
  final void Function(int day)? onDayTap;

  const MonthEnvelopeGridWidget({
    super.key,
    required this.month,
    required this.dayState,
    this.onDayTap,
  });

  int get _daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: _daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final state = dayState(day);
        final isTappable = state != DayCellState.futureDisabled;
        return GestureDetector(
          onTap: isTappable ? () => onDayTap?.call(day) : null,
          child: _DayCell(day: day, state: state),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final DayCellState state;

  const _DayCell({required this.day, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case DayCellState.written:
      case DayCellState.answered:
        return _EnvelopeCell(day: day, sealed: state == DayCellState.answered);
      case DayCellState.today:
        return _EmptyCell(day: day, highlight: true);
      case DayCellState.emptyPast:
      case DayCellState.futureDisabled:
        return _EmptyCell(
          day: day,
          highlight: false,
          faded: state == DayCellState.futureDisabled,
        );
    }
  }
}

class _EnvelopeCell extends StatelessWidget {
  final int day;
  final bool sealed;

  const _EnvelopeCell({required this.day, required this.sealed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.mail_rounded, color: Colors.white.withValues(alpha: 0.85), size: 16),
          Positioned(
            bottom: 3,
            child: Text(
              '$day',
              style: GoogleFonts.gowunBatang(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (sealed)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.goldColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  final int day;
  final bool highlight;
  final bool faded;

  const _EmptyCell({required this.day, required this.highlight, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight
              ? AppColors.accent
              : AppColors.divider.withValues(alpha: faded ? 0.35 : 0.7),
          width: highlight ? 1.6 : 1,
          style: BorderStyle.solid,
        ),
        color: highlight ? AppColors.accent.withValues(alpha: 0.08) : Colors.transparent,
      ),
      child: Center(
        child: Text(
          '$day',
          style: GoogleFonts.gowunBatang(
            color: faded
                ? AppColors.textHint.withValues(alpha: 0.4)
                : (highlight ? AppColors.accent : AppColors.textHint),
            fontSize: 11,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
