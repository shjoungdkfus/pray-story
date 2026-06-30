import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import 'widgets/settings_kit.dart';

/// 피드백을 받을 관리자 메일 주소.
const String _adminEmail = 'shjoung0@gmail.com';

const _categories = ['버그 신고', '기능 제안', '문의', '기타'];

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  String _category = _categories.first;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해 주세요.')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);

    setState(() => _isSending = true);
    try {
      await ref.read(supabaseProvider).from('feedback').insert({
        'user_id': user?.id,
        'email': user?.email,
        'category': _category,
        'message': message,
        'app_version': '1.0.0+1',
      });
      if (!mounted) return;
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소중한 의견 감사합니다. 잘 전달되었어요.')),
      );
      Navigator.pop(context);
    } on PostgrestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전송에 실패했어요. 메일로 보내기를 이용해 주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendByEmail() async {
    final message = _controller.text.trim();
    final profile = ref.read(profileProvider).valueOrNull;
    final subject = Uri.encodeComponent('[PrayStory 피드백] $_category');
    final bodyText = '$message\n\n---\n보낸사람: ${profile?.name ?? ''} '
        '(${profile?.email ?? ''})\n앱 버전: 1.0.0+1';
    final body = Uri.encodeComponent(bodyText);
    final uri = Uri.parse('mailto:$_adminEmail?subject=$subject&body=$body');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없어요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsDetailScaffold(
      title: '피드백',
      children: [
        Text(
          '앱을 사용하며 느낀 점이나 개선 아이디어를 들려주세요. '
          '보내주신 의견은 관리자에게 직접 전달돼요.',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          '유형',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _categories)
              _CategoryChip(
                label: c,
                selected: _category == c,
                onTap: () => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          '내용',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          maxLines: 7,
          maxLength: 1000,
          style: GoogleFonts.gowunBatang(
              color: AppColors.textPrimary, height: 1.5),
          decoration: InputDecoration(
            hintText: '내용을 자유롭게 적어 주세요.',
            hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.card,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.divider.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    '보내기',
                    style: GoogleFonts.gowunBatang(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: _sendByEmail,
            icon: const Icon(Icons.mail_outline, size: 18),
            label: Text(
              '메일 앱으로 보내기',
              style: GoogleFonts.gowunBatang(fontSize: 14),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider.withOpacity(0.7),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.gowunBatang(
            color: selected ? Colors.white : AppColors.textHint,
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
