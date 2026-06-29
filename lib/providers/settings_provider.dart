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

/// 앱 언어. (현재는 선택값 저장만 — 실제 다국어 번역은 추후 작업)
enum AppLanguage { ko, en }

extension AppLanguageLabel on AppLanguage {
  String get label => switch (this) {
        AppLanguage.ko => '한국어',
        AppLanguage.en => 'English',
      };
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const _prefsKey = 'app_language';

  LanguageNotifier() : super(AppLanguage.ko) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      state = AppLanguage.values.firstWhere(
        (l) => l.name == raw,
        orElse: () => AppLanguage.ko,
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
