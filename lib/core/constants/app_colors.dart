import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark = false;

  static void setMode(bool isDark) => _isDark = isDark;
  static bool get isDark => _isDark;

  // Light: 크림 종이 / Dark: 미드나잇 블루
  static Color get paper       => _isDark ? const Color(0xFF1B2133) : const Color(0xFFF5F0E1);
  static Color get background  => _isDark ? const Color(0xFF121624) : const Color(0xFFF5F0E1);
  static Color get card        => _isDark ? const Color(0xFF1B2133) : const Color(0xFFF5F0E1);
  static Color get searchBar   => _isDark ? const Color(0xFF22293D) : const Color(0xFFF5F0E1);
  static Color get bottomBar   => _isDark ? const Color(0xFF161B2A) : const Color(0xFFEFE6D0);
  static Color get textPrimary => _isDark ? const Color(0xFFE8E3D8) : const Color(0xFF150A02);
  static Color get textHint    => _isDark ? const Color(0xFF7B849E) : const Color(0xFF7A6050);
  static Color get divider     => _isDark ? const Color(0xFF252D42) : const Color(0xFFC4B49A);
  // accent: 텍스트·선택 강조 (다크에서 더스티 테라코타로 부드럽게)
  static Color get accent      => _isDark ? const Color(0xFFC47A6A) : const Color(0xFF8B1A0F);
  // FAB 원형 아이콘 정체성 — 라이트·다크 동일 고정
  static const fabColor = Color(0xFF8B1A0F);
}
