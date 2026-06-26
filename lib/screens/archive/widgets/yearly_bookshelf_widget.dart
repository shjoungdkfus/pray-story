import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'book_spine_painter.dart';

class BookMonthData {
  final DateTime month;
  final int letterCount;
  final BookSpineState state;

  const BookMonthData({
    required this.month,
    required this.letterCount,
    required this.state,
  });
}

class YearlyBookshelfWidget extends StatelessWidget {
  final List<BookMonthData> months; // 1월~12월, 12개
  final void Function(BookMonthData data)? onMonthTap;

  const YearlyBookshelfWidget({super.key, required this.months, this.onMonthTap});

  @override
  Widget build(BuildContext context) {
    final firstRow = months.sublist(0, 6);
    final secondRow = months.sublist(6, 12);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _ShelfRow(months: firstRow, onMonthTap: onMonthTap),
          const SizedBox(height: 6),
          const _ShelfDivider(),
          const SizedBox(height: 12),
          _ShelfRow(months: secondRow, onMonthTap: onMonthTap),
          const SizedBox(height: 6),
          const _ShelfDivider(),
        ],
      ),
    );
  }
}

class _ShelfDivider extends StatelessWidget {
  const _ShelfDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ShelfRow extends StatelessWidget {
  final List<BookMonthData> months;
  final void Function(BookMonthData data)? onMonthTap;

  const _ShelfRow({required this.months, this.onMonthTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: months
          .map((data) => Expanded(child: _BookSpine(data: data, onTap: onMonthTap)))
          .toList(),
    );
  }
}

class _BookSpine extends StatelessWidget {
  final BookMonthData data;
  final void Function(BookMonthData data)? onTap;

  const _BookSpine({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTappable = data.state != BookSpineState.future;
    final baseColor =
        AppColors.spineColors[(data.month.month - 1) % AppColors.spineColors.length];
    final labelColor = data.state == BookSpineState.future
        ? AppColors.textHint.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: data.state == BookSpineState.current ? 0.8 : 0.95);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: isTappable ? () => onTap?.call(data) : null,
        child: AspectRatio(
          aspectRatio: 0.42,
          child: CustomPaint(
            painter: BookSpinePainter(baseColor: baseColor, state: data.state),
            child: Center(
              child: Text(
                '${data.month.month}월',
                style: GoogleFonts.gowunBatang(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
