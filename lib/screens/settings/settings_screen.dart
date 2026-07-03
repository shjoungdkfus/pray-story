import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider);
    final ProfileModel? p = profile.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l.settingsTitle,
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
            label: l.settingsGroupMyInfo,
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: l.settingsMyInfo,
                subtitle: l.settingsMyInfoSubtitle,
                onTap: () => _push(context, ProfileEditScreen(profile: p)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: l.settingsGroupPreferences,
            children: [
              SettingsTile(
                icon: Icons.tune_rounded,
                title: l.settingsAppSettings,
                subtitle: l.settingsAppSettingsSubtitle,
                onTap: () => _push(context, const AppSettingsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: l.settingsGroupSupport,
            children: [
              SettingsTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: l.settingsFeedback,
                subtitle: l.settingsFeedbackSubtitle,
                onTap: () => _push(context, const FeedbackScreen()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SettingsGroup(
            label: l.settingsGroupAccount,
            children: [
              SettingsTile(
                icon: Icons.manage_accounts_outlined,
                title: l.settingsAccount,
                subtitle: l.settingsAccountSubtitle,
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
