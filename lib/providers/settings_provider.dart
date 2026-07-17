import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 화면 테마 모드. (현재는 선택값 저장만 — 실제 다크 팔레트 전환은 추후 작업)
enum AppThemeMode { system, light, dark }

extension AppThemeModeLabel on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.system => '시스템 설정',
        AppThemeMode.light => '라이트',
        AppThemeMode.dark => '다크',
      };
}

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  static const _prefsKey = 'app_theme_mode';

  ThemeModeNotifier() : super(AppThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      state = AppThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// 앱 언어. 기기 시스템 언어를 최초 실행 시 자동 감지(한국어 외에는 영어로 폴백)하고,
/// 사용자가 설정에서 수동으로 선택한 값이 있으면 그 값을 우선한다.
enum AppLanguage { ko, en }

extension AppLanguageLabel on AppLanguage {
  String get label => switch (this) {
        AppLanguage.ko => '한국어',
        AppLanguage.en => 'English',
      };
}

/// 지원 언어(ko/en) 중 기기 시스템 언어와 가장 가까운 것을 고른다.
/// 한국어 기기만 한국어로, 그 외 모든 언어는 영어로 폴백.
AppLanguage _detectDeviceLanguage() {
  return PlatformDispatcher.instance.locale.languageCode == 'ko'
      ? AppLanguage.ko
      : AppLanguage.en;
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const _prefsKey = 'app_language';

  LanguageNotifier() : super(_detectDeviceLanguage()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      state = AppLanguage.values.firstWhere(
        (l) => l.name == raw,
        orElse: () => state,
      );
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.name);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);
