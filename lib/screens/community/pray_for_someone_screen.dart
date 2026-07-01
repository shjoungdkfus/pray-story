import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'community_letter_write_screen.dart';

class PrayForSomeoneScreen extends ConsumerStatefulWidget {
  const PrayForSomeoneScreen({super.key});

  @override
  ConsumerState<PrayForSomeoneScreen> createState() => _PrayForSomeoneScreenState();
}

class _PrayForSomeoneScreenState extends ConsumerState<PrayForSomeoneScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CommunityLetterWriteScreen(recipientName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.favorite_border, color: AppColors.accent, size: 28),
            const SizedBox(height: 16),
            Text(
              '소중한 이에게\n기도 편지를 전해요',
              style: GoogleFonts.notoSansKr(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '이름을 입력하면 그 사람을 위한\n기도 편지를 쓸 수 있어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.textHint,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              '받는 이',
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '예) 엄마, 친구 민준이, ...',
                hintStyle: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              onSubmitted: (_) => _next(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  '편지 쓰러 가기',
                  style: GoogleFonts.notoSansKr(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
