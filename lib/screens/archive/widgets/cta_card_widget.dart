import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CtaCardWidget extends StatelessWidget {
  final bool isWrittenToday;
  final VoidCallback? onWriteTap;

  const CtaCardWidget({super.key, required this.isWrittenToday, this.onWriteTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isWrittenToday ? _buildDoneState() : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Text(
          '아직 오늘의 페이지가 비어있어요',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onWriteTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '오늘의 편지 쓰기',
              style: GoogleFonts.gowunBatang(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
        const SizedBox(width: 8),
        Text(
          '오늘의 편지를 이미 보냈어요',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
