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
  static Color get textHint    => _isDark ? const Color(0xFF8F897F) : const Color(0xFF9C8A7A);
  static Color get divider     => _isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEAE0D5);
  // 카드 테두리 (배경과 분리된 카드 형태의 외곽선)
  static Color get cardBorder  => _isDark ? const Color(0xFF333333) : const Color(0xFFEDE4D8);
  // accent: 텍스트·선택 강조 — 순검정 FAB과 구분되는 차콜 그레이, 라이트·다크 동일
  static Color get accent      => const Color(0xFF4D4D4D);
  // 달력 기록 표시 원 — 다크에선 밝은 회색(저조도 배경에서 묻히지 않게), 라이트는 차콜 유지
  static Color get calendarMark => _isDark ? const Color(0xFFB5AFA3) : const Color(0xFF4D4D4D);
  // 설정 타일 아이콘 — 다크에선 accent보다 한 톤 밝게(어두운 카드에서 또렷하게), 라이트는 차콜 유지
  static Color get settingsIcon => _isDark ? const Color(0xFF8F897F) : const Color(0xFF4D4D4D);
  // FAB 원형 아이콘 정체성(메인 브랜드 포인트) — 라이트·다크 동일 고정, 순검정 유지
  static const fabColor = Color(0xFF000000);
  // 파괴적 동작(회원탈퇴 등) 강조 — 라이트·다크 동일 고정, 톤은 앱의 따뜻한 팔레트에 맞춘 브릭 레드
  static const danger = Color(0xFFC0392B);
}
