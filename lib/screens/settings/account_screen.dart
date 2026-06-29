import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/settings_kit.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await _showConfirmDialog(
      context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠어요?',
      confirmLabel: '로그아웃',
    );
    if (ok != true) return;
    await ref.read(supabaseProvider).auth.signOut();
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final ok = await _showConfirmDialog(
      context,
      title: '회원 탈퇴',
      message: '탈퇴하면 계정이 비활성화되고 더 이상 로그인할 수 없어요.\n'
          '정말 탈퇴하시겠어요?',
      confirmLabel: '탈퇴하기',
      destructive: true,
    );
    if (ok != true) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(supabaseProvider).from('profiles').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
      await ref.read(supabaseProvider).auth.signOut();
    } on PostgrestException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴 처리 중 문제가 발생했어요. 다시 시도해 주세요.')),
      );
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '취소',
              style: GoogleFonts.gowunBatang(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: GoogleFonts.gowunBatang(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsDetailScaffold(
      title: '계정',
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.logout,
              title: '로그아웃',
              showChevron: false,
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.person_remove_outlined,
              title: '회원 탈퇴',
              destructive: true,
              showChevron: false,
              onTap: () => _confirmWithdraw(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '탈퇴 시 계정은 비활성화 처리돼요. 작성하신 기도 기록의 완전 삭제를 '
            '원하시면 피드백으로 문의해 주세요.',
            style: GoogleFonts.gowunBatang(
              color: AppColors.textHint,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
