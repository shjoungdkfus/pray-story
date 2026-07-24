import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_prayer_store.dart';
import 'widgets/settings_kit.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await _showConfirmDialog(
      context,
      title: l.accountLogout,
      message: l.accountLogoutConfirm,
      confirmLabel: l.accountLogout,
    );
    if (ok != true) return;
    // 로그아웃 시 기도문 평문(draft·오프라인 캐시)이 기기에 남지 않도록 삭제 (FR-007).
    await LocalPrayerStore.clearAll();
    await ref.read(supabaseProvider).auth.signOut();
    // _RootGate(루트)는 signOut으로 LoginScreen이 되지만, 위에 쌓인
    // 설정/계정 화면을 걷어내야 로그인 화면이 실제로 드러난다.
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await _showConfirmDialog(
      context,
      title: l.accountWithdraw,
      message: l.accountWithdrawConfirm,
      confirmLabel: l.accountWithdrawButton,
      destructive: true,
    );
    if (ok != true) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(supabaseProvider).functions.invoke('delete-account');
      // 서버에서 계정이 이미 삭제됐으므로 로컬 세션만 정리한다.
      await LocalPrayerStore.clearAll(); // 로컬 기도문 캐시·draft도 제거 (FR-007).
      try {
        await ref.read(supabaseProvider).auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
      // 탈퇴 후에도 위에 쌓인 설정/계정 화면을 걷어내야 로그인 화면이 드러난다.
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FunctionException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).accountWithdrawFailed)),
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
          style: GoogleFonts.notoSansKr(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.notoSansKr(
            color: AppColors.textHint,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context).buttonCancel,
              style: GoogleFonts.notoSansKr(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: GoogleFonts.notoSansKr(
                color: destructive ? AppColors.danger : AppColors.textPrimary,
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
    final l = AppLocalizations.of(context);
    return SettingsDetailScaffold(
      title: l.settingsAccount,
      children: [
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.logout,
              title: l.accountLogout,
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
              title: l.accountWithdraw,
              showChevron: false,
              onTap: () => _confirmWithdraw(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            l.accountWithdrawNote,
            style: GoogleFonts.notoSansKr(
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
