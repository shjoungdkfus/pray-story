import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/community_models.dart';

class InviteGroupScreen extends StatelessWidget {
  final CommunityGroup group;
  const InviteGroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final initial = group.name.isNotEmpty ? group.name.characters.first : '?';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                l.inviteHeading,
                style: GoogleFonts.notoSansKr(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.inviteDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // 그룹 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                group.name,
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              // 초대 코드
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: group.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.inviteCodeCopied)),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.searchBar,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group.inviteCode.split('').join(' '),
                        style: GoogleFonts.notoSansKr(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.copy, color: AppColors.textHint, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 공유 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share(
                      l.inviteShareMessage(group.name, group.inviteCode),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: Text(l.inviteShareButton, style: GoogleFonts.notoSansKr(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
