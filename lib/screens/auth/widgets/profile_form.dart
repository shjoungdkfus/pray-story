import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// 출생연도 → "30대" 같은 연령대 라벨. null이면 미선택.
String ageGroupLabel(int? birthYear) {
  if (birthYear == null) return '선택 안 함';
  final age = DateTime.now().year - birthYear;
  if (age < 10) return '10대 미만';
  final decade = (age ~/ 10) * 10;
  return '$decade대';
}

/// 성별 저장값 → 표시 라벨. 레거시 '남'/'여' 값도 흡수한다.
String genderLabel(String? g) {
  switch (g) {
    case '남':
    case '남자':
      return '남자';
    case '여':
    case '여자':
      return '여자';
    default:
      return '선택 안 함';
  }
}

/// 이름에서 아바타용 이니셜(최대 2자)을 뽑는다.
String _avatarInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  final chars = trimmed.characters;
  return chars.length <= 2 ? trimmed : chars.takeLast(2).toString();
}

/// 프로필 입력 카드 묶음 — 이름·프로필 사진·교회·성별·연령대.
/// 회원가입 Step2와 설정의 프로필 수정 화면이 공유한다.
class ProfileFormFields extends StatelessWidget {
  final String name;
  final String? church;
  final String? gender;
  final int? birthYear;
  final VoidCallback onTapName;
  final VoidCallback onTapPhoto;
  final VoidCallback onTapChurch;
  final VoidCallback onTapGender;
  final VoidCallback onTapAge;

  const ProfileFormFields({
    super.key,
    required this.name,
    required this.church,
    required this.gender,
    required this.birthYear,
    required this.onTapName,
    required this.onTapPhoto,
    required this.onTapChurch,
    required this.onTapGender,
    required this.onTapAge,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _avatarInitials(name);

    return Column(
      children: [
        _row(
          label: '이름',
          onTap: onTapName,
          value: _valueText(
            name.trim().isEmpty ? '이름 입력' : name.trim(),
            muted: name.trim().isEmpty,
          ),
        ),
        const SizedBox(height: 12),
        _row(
          label: '프로필 사진',
          onTap: onTapPhoto,
          value: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: initials.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 22)
                : Text(
                    initials,
                    style: GoogleFonts.gowunBatang(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        _row(
          label: '교회',
          onTap: onTapChurch,
          value: _valueText(
            (church == null || church!.trim().isEmpty) ? '교회 선택' : church!.trim(),
            muted: church == null || church!.trim().isEmpty,
          ),
        ),
        const SizedBox(height: 12),
        _row(
          label: '성별',
          onTap: onTapGender,
          value: _valueText(
            gender == null ? '선택' : genderLabel(gender),
            muted: gender == null,
          ),
        ),
        const SizedBox(height: 12),
        _row(
          label: '연령대',
          onTap: onTapAge,
          value: _valueText(
            birthYear == null ? '선택' : ageGroupLabel(birthYear),
            muted: birthYear == null,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '성별과 연령대 정보는 공동체에 공개되지 않습니다.',
          textAlign: TextAlign.center,
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _valueText(String text, {bool muted = false}) => Text(
        text,
        style: GoogleFonts.gowunBatang(
          color: muted ? AppColors.textHint : AppColors.textPrimary,
          fontSize: 15,
          fontWeight: muted ? FontWeight.normal : FontWeight.w600,
        ),
      );

  Widget _row({
    required String label,
    required Widget value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.gowunBatang(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              value,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── 입력 바텀시트들 ───────────────────────────

Widget _sheetHandle() => Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

ButtonStyle _confirmButtonStyle() => ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

/// 텍스트 입력 시트 (이름·교회). 확인 시 입력값을, 취소 시 null 반환.
Future<String?> showProfileTextSheet(
  BuildContext context, {
  required String title,
  String? initial,
  String hint = '',
  int maxLength = 20,
}) {
  final controller = TextEditingController(text: initial ?? '');
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
              child: Text(
                title,
                style: GoogleFonts.gowunBatang(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLength: maxLength,
                style: GoogleFonts.gowunBatang(color: AppColors.textPrimary),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.background,
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider.withOpacity(0.7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  style: _confirmButtonStyle(),
                  child: Text(
                    '확인',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
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

/// 성별 선택 시트. 선택값('남자'/'여자') 또는 null 반환.
Future<String?> showGenderSheet(BuildContext context, {String? current}) {
  final normalized = genderLabel(current);
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
            child: Text(
              '성별',
              style: GoogleFonts.gowunBatang(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final g in ['남자', '여자'])
            _SelectRow(
              label: g,
              selected: normalized == g,
              onTap: () => Navigator.pop(ctx, g),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

/// 출생연도 선택 시트(휠). 확인 시 연도, 취소 시 null 반환.
Future<int?> showBirthYearSheet(BuildContext context, {int? current}) {
  final now = DateTime.now().year;
  const minYear = 1930;
  final years = [for (var y = now; y >= minYear; y--) y];
  final initialIndex = current != null && years.contains(current)
      ? years.indexOf(current)
      : years.indexOf(now - 30);
  final safeIndex = initialIndex < 0 ? 0 : initialIndex;
  var picked = years[safeIndex];

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
            child: Text(
              '연령대 계산을 위해 출생연도를 선택해주세요',
              style: GoogleFonts.gowunBatang(
                color: AppColors.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: safeIndex),
              itemExtent: 40,
              backgroundColor: AppColors.card,
              onSelectedItemChanged: (i) => picked = years[i],
              children: [
                for (final y in years)
                  Center(
                    child: Text(
                      '$y년생',
                      style: GoogleFonts.gowunBatang(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, picked),
                style: _confirmButtonStyle(),
                child: Text(
                  '확인',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SelectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.gowunBatang(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: AppColors.accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
