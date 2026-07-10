import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// 모임 생성 시 기본으로 보여줄 아이콘.
const String defaultGroupIcon = '📖';

/// 모임 아이콘(이모지) 선택 바텀시트 — 전체 이모지 카테고리(스마일리·하트·동물·음식 등)를
/// 탐색·검색할 수 있는 풀 피커. 선택 시 해당 이모지를 반환하고, 취소(바깥 탭)하면 null을
/// 반환한다. DB 반영 등 후처리는 호출부 책임.
Future<String?> showGroupIconPicker(BuildContext context, {required String current}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _GroupIconPickerSheet(),
  );
}

class _GroupIconPickerSheet extends StatelessWidget {
  const _GroupIconPickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).groupIconPick,
                  style: GoogleFonts.notoSansKr(fontSize: 13, color: AppColors.textHint, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 380,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) => Navigator.pop(context, emoji.emoji),
                config: Config(
                  height: 380,
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: AppColors.background,
                    columns: 8,
                    emojiSizeMax: 26,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: AppColors.background,
                    indicatorColor: AppColors.accent,
                    iconColorSelected: AppColors.accent,
                    iconColor: AppColors.textHint,
                    backspaceColor: AppColors.accent,
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: AppColors.background,
                    buttonColor: AppColors.background,
                    buttonIconColor: AppColors.accent,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: AppColors.background,
                    buttonIconColor: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
