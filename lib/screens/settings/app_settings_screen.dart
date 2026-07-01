import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import 'notification_settings_screen.dart';
import 'widgets/settings_kit.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  void _pickTheme(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    _showSelectSheet(
      context: context,
      title: '화면 테마',
      footnote: '선택한 테마는 즉시 적용됩니다.',
      options: [
        for (final m in AppThemeMode.values)
          _SelectOption(
            icon: switch (m) {
              AppThemeMode.system => Icons.brightness_auto_outlined,
              AppThemeMode.light => Icons.light_mode_outlined,
              AppThemeMode.dark => Icons.dark_mode_outlined,
            },
            label: m.label,
            selected: current == m,
            onTap: () => ref.read(themeModeProvider.notifier).setMode(m),
          ),
      ],
    );
  }

  void _pickLanguage(BuildContext context, WidgetRef ref) {
    final current = ref.read(languageProvider);
    _showSelectSheet(
      context: context,
      title: '언어',
      footnote: '※ 화면 번역은 다음 업데이트에서 제공될 예정이에요.',
      options: [
        for (final l in AppLanguage.values)
          _SelectOption(
            icon: Icons.language,
            label: l.label,
            selected: current == l,
            onTap: () => ref.read(languageProvider.notifier).setLanguage(l),
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
    final theme = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return SettingsDetailScaffold(
      title: '앱 설정',
      children: [
        SettingsGroup(
          label: '알림',
          children: [
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: '알림 설정',
              subtitle: '기도 시간 알림을 관리해요',
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
          label: '화면',
          children: [
            SettingsTile(
              icon: Icons.palette_outlined,
              title: '화면 테마',
              trailingValue: theme.label,
              onTap: () => _pickTheme(context, ref),
            ),
            SettingsTile(
              icon: Icons.translate_outlined,
              title: '언어',
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
