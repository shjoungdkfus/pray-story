import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import 'notification_settings_screen.dart';
import 'widgets/settings_kit.dart';

/// 테마 모드 라벨을 현재 언어로 반환한다. (enum 라벨은 로케일에 따라 달라짐)
String themeModeLabel(AppThemeMode m, AppLocalizations l) => switch (m) {
      AppThemeMode.system => l.themeSystem,
      AppThemeMode.light => l.themeLight,
      AppThemeMode.dark => l.themeDark,
    };

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  void _pickTheme(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);
    _showSelectSheet(
      context: context,
      title: l.themeSheetTitle,
      footnote: l.themeSheetFootnote,
      options: [
        for (final m in AppThemeMode.values)
          _SelectOption(
            icon: switch (m) {
              AppThemeMode.system => Icons.brightness_auto_outlined,
              AppThemeMode.light => Icons.light_mode_outlined,
              AppThemeMode.dark => Icons.dark_mode_outlined,
            },
            label: themeModeLabel(m, l),
            selected: current == m,
            onTap: () => ref.read(themeModeProvider.notifier).setMode(m),
          ),
      ],
    );
  }

  void _pickLanguage(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.read(languageProvider);
    _showSelectSheet(
      context: context,
      title: l.languageSheetTitle,
      footnote: l.languageSheetFootnote,
      options: [
        for (final lang in AppLanguage.values)
          _SelectOption(
            icon: Icons.language,
            label: lang.label,
            selected: current == lang,
            onTap: () =>
                ref.read(languageProvider.notifier).setLanguage(lang),
          ),
      ],
    );
  }

  void _showSelectSheet({
    required BuildContext context,
    required String title,
    required String footnote,
    required List<_SelectOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
              child: Text(
                title,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final o in options)
              SettingsRadioTile(
                icon: o.icon,
                title: o.label,
                selected: o.selected,
                onTap: () {
                  o.onTap();
                  Navigator.pop(ctx);
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Text(
                footnote,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return SettingsDetailScaffold(
      title: l.appSettingsTitle,
      children: [
        SettingsGroup(
          label: l.appSettingsGroupNotifications,
          children: [
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: l.appSettingsNotification,
              subtitle: l.appSettingsNotificationSubtitle,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SettingsGroup(
          label: l.appSettingsGroupDisplay,
          children: [
            SettingsTile(
              icon: Icons.palette_outlined,
              title: l.appSettingsTheme,
              trailingValue: themeModeLabel(theme, l),
              onTap: () => _pickTheme(context, ref),
            ),
            SettingsTile(
              icon: Icons.translate_outlined,
              title: l.appSettingsLanguage,
              trailingValue: language.label,
              onTap: () => _pickLanguage(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectOption {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
}
