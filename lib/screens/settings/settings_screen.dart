import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/profile_provider.dart';
import 'account_screen.dart';
import 'app_settings_screen.dart';
import 'feedback_screen.dart';
import 'profile_edit_screen.dart';
import 'widgets/settings_kit.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final ProfileModel? p = profile.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '설정',
          style: GoogleFonts.notoSansKr(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          const SizedBox(height: 8),
          SettingsGroup(
            label: '내 정보',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: '내 정보',
                subtitle: '프로필을 확인하고 수정해요',
                onTap: () => _push(context, ProfileEditScreen(profile: p)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: '환경설정',
            children: [
              SettingsTile(
                icon: Icons.tune_rounded,
                title: '앱 설정',
                subtitle: '알림, 테마, 언어',
                onTap: () => _push(context, const AppSettingsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: '지원',
            children: [
              SettingsTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: '피드백',
                subtitle: '관리자에게 의견을 보내요',
                onTap: () => _push(context, const FeedbackScreen()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: '계정',
            children: [
              SettingsTile(
                icon: Icons.manage_accounts_outlined,
                title: '계정',
                subtitle: '로그아웃, 회원 탈퇴',
                onTap: () => _push(context, const AccountScreen()),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'PrayStory · v1.0.0',
              style: GoogleFonts.notoSansKr(
                color: AppColors.textHint,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
