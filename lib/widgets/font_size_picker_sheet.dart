import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../providers/font_size_provider.dart';

class FontSizePickerSheet extends ConsumerWidget {
  const FontSizePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(fontSizeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '글자 크기',
            style: GoogleFonts.notoSansKr(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sizeOption(context, ref, 11.0, '작게', current),
              _sizeOption(context, ref, 15.0, '보통', current),
              _sizeOption(context, ref, 25.0, '크게', current),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sizeOption(
    BuildContext context,
    WidgetRef ref,
    double size,
    String label,
    double current,
  ) {
    final isSelected = (current - size).abs() < 0.1;
    return GestureDetector(
      onTap: () {
        ref.read(fontSizeProvider.notifier).setSize(size);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              '가',
              style: GoogleFonts.notoSansKr(
                fontSize: (size * 0.6).clamp(11.0, 28.0),
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 11,
              color: isSelected ? AppColors.accent : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
