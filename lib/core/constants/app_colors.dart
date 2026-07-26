import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark = false;

  static void setMode(bool isDark) => _isDark = isDark;
  static bool get isDark => _isDark;

  // Light: 배경 흰색 / 페이지·카드 크림(종이색) / Dark: 페이지는 완전 검정, 카드(종이)는 옅은 검정(뉴트럴 그레이)
  static Color get paper       => _isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  static Color get background  => _isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  static Color get card        => _isDark ? const Color(0xFF242424) : const Color(0xFFF8F4EC);
  static Color get searchBar   => _isDark ? const Color(0xFF242424) : const Color(0xFFFFFFFF);
  static Color get bottomBar   => _isDark ? const Color(0xFF121212) : const Color(0xFFEFE6D0);
  static Color get textPrimary => _isDark ? const Color(0xFFD9D4CC) : const Color(0xFF150A02);
  // textHint: 보조 텍스트. 종전 값(라이트 #9C8A7A / 다크 #8F897F)은 각각 3.02:1 / 4.47:1로
  // WCAG AA(4.5:1)에 미달해 한 단계씩 대비를 높였다. (라이트 4.73:1 / 다크 5.09:1 on card)
  static Color get textHint    => _isDark ? const Color(0xFF9A948A) : const Color(0xFF7A6A5C);
  static Color get divider     => _isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEAE0D5);
  // 카드 테두리 (배경과 분리된 카드 형태의 외곽선)
  static Color get cardBorder  => _isDark ? const Color(0xFF333333) : const Color(0xFFEDE4D8);
  // accent: **채움(버튼·배지 배경)용** 강조색. 위에 흰 글씨가 얹히므로 어두운 톤을 유지하되,
  // 다크에선 검은 배경과 형태가 구분되도록 한 단계 밝힌다.
  // (다크 #696969 — 배경 대비 3.83:1 >= 3, 흰 글씨 대비 5.49:1 >= 4.5)
  static Color get accent      => _isDark ? const Color(0xFF696969) : const Color(0xFF4D4D4D);
  // accentText: **전경(글자·아이콘·테두리)용** 강조색. accent를 그대로 전경에 쓰면
  // 다크 배경(#000000/#242424)에서 1.84~2.48:1로 WCAG AA에 한참 못 미치므로
  // calendarMark와 같은 밝은 톤으로 분기한다. (다크 card 대비 7.12:1)
  static Color get accentText  => _isDark ? const Color(0xFFB5AFA3) : const Color(0xFF4D4D4D);
  // 달력 기록 표시 원 — 다크에선 밝은 회색(저조도 배경에서 묻히지 않게), 라이트는 차콜 유지
  static Color get calendarMark => _isDark ? const Color(0xFFB5AFA3) : const Color(0xFF4D4D4D);
  // 설정 타일 아이콘 — 다크에선 accent보다 한 톤 밝게(어두운 카드에서 또렷하게), 라이트는 차콜 유지
  static Color get settingsIcon => _isDark ? const Color(0xFF8F897F) : const Color(0xFF4D4D4D);
  // FAB 원형 아이콘 정체성(메인 브랜드 포인트) — 라이트·다크 동일 고정, 순검정 유지
  static const fabColor = Color(0xFF000000);
  // 파괴적 동작(기도문·편지 삭제, 회원탈퇴 등) 강조 — 앱의 따뜻한 팔레트에 맞춘 브릭 레드.
  // 다크에선 원래 값(#C0392B)이 card 대비 2.85:1로 미달이라 밝은 톤으로 분기한다. (다크 card 대비 5.13:1)
  static Color get danger      => _isDark ? const Color(0xFFE57373) : const Color(0xFFC0392B);
}
