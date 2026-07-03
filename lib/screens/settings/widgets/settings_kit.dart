import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// 설정 상세 페이지 공통 Scaffold — 뒤로가기 화살표 + 제목.
class SettingsDetailScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const SettingsDetailScaffold({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 32),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansKr(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(padding: padding, children: children),
    );
  }
}

/// 묶음 라벨 + 둥근 카드. 자식 타일 사이에 얇은 구분선을 자동으로 넣는다.
class SettingsGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;

  const SettingsGroup({super.key, this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Padding(
          padding: EdgeInsets.only(left: 64),
          child: Divider(height: 1, thickness: 1, color: AppColors.divider),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(
              label!,
              style: GoogleFonts.notoSansKr(
                color: AppColors.textHint,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// 아이콘 칩 + 제목(+부제) + 우측 값/쉐브론. 누르면 onTap.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String? trailingValue;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailingValue,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.accent : (iconColor ?? AppColors.accent);
    final titleColor = destructive ? AppColors.accent : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accent.withOpacity(0.06),
        highlightColor: AppColors.accent.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansKr(
                        color: titleColor,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.textHint,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailingValue != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    trailingValue!,
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textHint,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              if (showChevron && !destructive) ...[
                const SizedBox(width: 2),
                Icon(Icons.chevron_right,
                    color: AppColors.textHint, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 상단 프로필 카드 — 이니셜 아바타 + 이름 + 이메일 + 쉐브론.
class SettingsProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;

  const SettingsProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final initial = name.trim().isNotEmpty ? name.trim().characters.first : '?';

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: GoogleFonts.notoSansKr(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.isNotEmpty ? name : l.settingsNoNamePlaceholder,
                      style: GoogleFonts.notoSansKr(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: GoogleFonts.notoSansKr(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// 단일 선택(라디오) 타일 — 테마/언어 선택용. 선택 시 체크 표시.
class SettingsRadioTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsRadioTile({
    super.key,
    this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accent.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 20,
                    color: selected ? AppColors.accent : AppColors.textHint),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded,
                    color: AppColors.accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
