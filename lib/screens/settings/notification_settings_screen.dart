import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/prayer_alarm_model.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'widgets/settings_kit.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  String _fmt(String locale, int hour, int minute) {
    return DateFormat.jm(locale)
        .format(DateTime(2024, 1, 1, hour, minute));
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      // 종전엔 ColorScheme.light를 고정해 다크 모드에서도 라이트 슬롯(다이얼 배경,
      // 선택 하이라이트 등)이 남아 어두운 면에 어두운 요소가 겹쳤다(PS-UI-14).
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: (AppColors.isDark
                  ? const ColorScheme.dark()
                  : const ColorScheme.light())
              .copyWith(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
  }

  /// 알림 권한을 요청하고, 거부됐으면 사용자에게 알린다.
  /// 종전엔 반환값을 버려서 권한이 없어도 알람이 ON으로 켜지고 사용자는
  /// 울리지 않는 알람을 설정된 것으로 믿게 됐다(PS-UI-08).
  static Future<bool> _ensurePermission(BuildContext context) async {
    final granted = await NotificationService.requestPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).notifPermissionDenied),
        ),
      );
    }
    return granted;
  }

  Future<void> _addAlarm(BuildContext context, WidgetRef ref) async {
    final picked = await _pickTime(context, const TimeOfDay(hour: 7, minute: 0));
    if (picked == null) return;
    if (!context.mounted) return;
    if (!await _ensurePermission(context)) return;
    if (!context.mounted) return;
    await ref.read(prayerAlarmsProvider.notifier).addAlarm(picked.hour, picked.minute);
  }

  Future<void> _editTime(
      BuildContext context, WidgetRef ref, PrayerAlarm alarm) async {
    final picked = await _pickTime(
        context, TimeOfDay(hour: alarm.hour, minute: alarm.minute));
    if (picked == null) return;
    if (!context.mounted) return;
    await ref
        .read(prayerAlarmsProvider.notifier)
        .updateTime(alarm.id, picked.hour, picked.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(prayerAlarmsProvider);
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return SettingsDetailScaffold(
      title: l.appSettingsNotification,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentText.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accentText, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.notifSettingsInfo,
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (alarms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.notifications_off_outlined,
                    color: AppColors.textHint, size: 40),
                const SizedBox(height: 12),
                Text(
                  l.notifEmptyTitle,
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          SettingsGroup(
            label: l.notifDailyGroup,
            children: [
              for (final alarm in alarms)
                _AlarmTile(
                  alarm: alarm,
                  timeLabel: _fmt(locale, alarm.hour, alarm.minute),
                  onTapTime: () => _editTime(context, ref, alarm),
                  onToggle: (v) async {
                    // 권한이 없으면 토글을 켜지 않는다 — 켜두면 울리지 않는 알람이
                    // 켜진 것처럼 보인다(PS-UI-08).
                    if (v && !await _ensurePermission(context)) return;
                    if (!context.mounted) return;
                    await ref
                        .read(prayerAlarmsProvider.notifier)
                        .toggleAlarm(alarm.id);
                  },
                  onDelete: () => ref
                      .read(prayerAlarmsProvider.notifier)
                      .removeAlarm(alarm.id),
                ),
            ],
          ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addAlarm(context, ref),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              l.notifAddButton,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentText,
              side: BorderSide(color: AppColors.accentText, width: 1.3),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlarmTile extends StatelessWidget {
  final PrayerAlarm alarm;
  final String timeLabel;
  final VoidCallback onTapTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _AlarmTile({
    required this.alarm,
    required this.timeLabel,
    required this.onTapTime,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapTime,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 20,
                      color: alarm.enabled
                          ? AppColors.accentText
                          : AppColors.textHint),
                  const SizedBox(width: 12),
                  Text(
                    timeLabel,
                    style: GoogleFonts.notoSansKr(
                      color: alarm.enabled
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                color: AppColors.textHint, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          Switch(
            value: alarm.enabled,
            onChanged: onToggle,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.divider,
          ),
        ],
      ),
    );
  }
}
