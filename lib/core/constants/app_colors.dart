import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFEFCF8);   // 거의 흰색, 미세한 크림
  static const card = Color(0xFFF5EBD5);          // 크림 베이지 (배경과 대비 강화)
  static const searchBar = Color(0xFFEDE0C4);     // 검색바 — card와 bottomBar 사이
  static const bottomBar = Color(0xFFEFE6D0);     // 카드보다 살짝 진한 베이지
  static const textPrimary = Color(0xFF150A02);   // 진한 에스프레소 브라운
  static const accent = Color(0xFF8B1A0F);        // 깊은 레드 (가시성 강화)
  static const textHint = Color(0xFF7A6050);      // 중간 브라운 (계층 구분)
  static const divider = Color(0xFFC4B49A);       // 선명한 구분선

  // 서신함 책장 — 책등 색상 순환 팔레트
  static const spineColors = [
    Color(0xFF8B1A0F),
    Color(0xFF60041B),
    Color(0xFF9B2D1E),
    Color(0xFF3C191E),
    Color(0xFF6E2A12),
    Color(0xFF4A0F22),
  ];
  static const goldColor = Color(0xFFD2AF6E);     // 책등 금박 장식
}
