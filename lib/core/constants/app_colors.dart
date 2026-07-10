import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark = false;

  static void setMode(bool isDark) => _isDark = isDark;
  static bool get isDark => _isDark;

  // Light: 배경 흰색 / 페이지·카드 크림(종이색) / Dark: Midnight Devotion(B) 깊은 미드나잇
  static Color get paper       => _isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
  static Color get background  => _isDark ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
  static Color get card        => _isDark ? const Color(0xFF161B22) : const Color(0xFFF8F4EC);
  static Color get searchBar   => _isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
  static Color get bottomBar   => _isDark ? const Color(0xFF161B22) : const Color(0xFFEFE6D0);
  static Color get textPrimary => _isDark ? const Color(0xFFE6EDF3) : const Color(0xFF150A02);
  static Color get textHint    => _isDark ? const Color(0xFF7D8590) : const Color(0xFF9C8A7A);
  static Color get divider     => _isDark ? const Color(0xFF21262D) : const Color(0xFFEAE0D5);
  // 카드 테두리 (배경과 분리된 카드 형태의 외곽선)
  static Color get cardBorder  => _isDark ? const Color(0xFF30363D) : const Color(0xFFEDE4D8);
  // accent: 텍스트·선택 강조 — 순검정 FAB과 구분되는 차콜 그레이, 라이트·다크 동일
  static Color get accent      => const Color(0xFF4D4D4D);
  // FAB 원형 아이콘 정체성(메인 브랜드 포인트) — 라이트·다크 동일 고정, 순검정 유지
  static const fabColor = Color(0xFF000000);
}
