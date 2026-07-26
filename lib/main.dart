import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase/supabase_config.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/prayer_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_step2_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/record/record_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/write/prayer_write_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);
  await NotificationService.initialize();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
  );
  await GoogleSignIn.instance.initialize(
    serverClientId: SupabaseConfig.googleWebClientId,
  );

  runApp(const ProviderScope(child: PrayStoryApp()));
}

class PrayStoryApp extends ConsumerWidget {
  const PrayStoryApp({super.key});

  ThemeData _buildTheme(bool isDark) {
    AppColors.setMode(isDark);
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.fabColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.notoSansKrTextTheme(
        isDark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.notoSansKr(
          color: isDark ? AppColors.background : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final isDark = switch (mode) {
      AppThemeMode.dark => true,
      AppThemeMode.light => false,
      // platformDispatcher를 직접 읽으면 기기 테마가 바뀌어도 rebuild가 안 걸린다.
      // MediaQuery로 구독해야 시스템 모드가 실시간으로 따라간다(PS-UI-07).
      AppThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    return MaterialApp(
      title: 'PrayStory',
      debugShowCheckedModeBanner: false,
      locale: Locale(language.name),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _buildTheme(isDark),
      // OS 접근성 폰트배율(최대 200%)이 자체 폰트크기 설정(fontSizeProvider)과
      // 곱연산으로 중첩돼 달력 그리드가 잘려 보이는 등 레이아웃이 깨짐(실기기
      // 확인됨, PS-UI-01). 확대 방향만 1.0으로 막고 축소는 그대로 둔다 —
      // 본문 글자 확대는 앱 자체 폰트크기 기능으로 이미 제공하고 있어서다.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.0),
          ),
          child: child!,
        );
      },
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  Widget _loadingScreen() => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentText),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      loading: _loadingScreen,
      error: (e, _) => const LoginScreen(),
      data: (state) {
        if (state.session == null) return const LoginScreen();
        // 세션은 있지만 profiles 행이 없으면(카카오/구글 첫 로그인) 온보딩으로 보낸다.
        final profileAsync = ref.watch(profileProvider);
        return profileAsync.when(
          loading: _loadingScreen,
          error: (e, _) => const LoginScreen(),
          data: (profile) {
            if (profile == null) {
              return const SignupStep2Screen(email: null, password: null);
            }
            return const MainShell();
          },
        );
      },
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // 탭 인덱스: 0=서신서, 1=기도기록, 2=커뮤니티, 3=설정
  static const _screens = [HomeScreen(), RecordScreen(), CommunityScreen(), SettingsScreen()];

  // 모든 화면 전환에 공통으로 쓰는 통일된 전환 속도·곡선
  static const _transitionDuration = Duration(milliseconds: 280);
  static const _transitionCurve = Curves.easeInOut;

  void _openWriteSheet() {
    final selectedDate = ref.read(selectedDateProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: PrayerWriteScreen(targetDate: selectedDate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(shellTabProvider);
    final previousTab = ref.watch(previousTabProvider);

    void switchTab(int index) {
      ref.read(previousTabProvider.notifier).state = null;
      ref.read(shellTabProvider.notifier).state = index;
    }

    return PopScope(
      canPop: previousTab == null && selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (previousTab != null) {
          ref.read(shellTabProvider.notifier).state = previousTab;
          ref.read(previousTabProvider.notifier).state = null;
        } else {
          // 기도기록·설정에서 뒤로가기 → 서신서(루트)로
          ref.read(shellTabProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: List.generate(_screens.length, (i) {
            final isActive = selectedIndex == i;
            return AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: _transitionDuration,
              curve: _transitionCurve,
              child: IgnorePointer(
                ignoring: !isActive,
                // RepaintBoundary: 각 화면을 독립 레이어로 캐시해서
                // 페이드 중 화면 전체를 매 프레임 다시 그리지 않도록 한다.
                child: RepaintBoundary(child: _screens[i]),
              ),
            );
          }),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.bottomBar,
            border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book,
                    label: 'PrayStory',
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      // 메인 탭을 누르면 항상 오늘로 돌아온다
                      ref.read(selectedDateProvider.notifier).state =
                          DateTime.now();
                      switchTab(0);
                    },
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_month,
                    label: AppLocalizations.of(context).recordTitle,
                    isSelected: selectedIndex == 1,
                    onTap: () => switchTab(1),
                  ),
                  Expanded(
                    child: Center(
                      // GestureDetector는 눌림 표현이 없어 옆 탭(InkWell)과 반응이 갈렸다.
                      // 다크에선 순검정 FAB이 bottomBar(#121212)와 1.12:1이라 원형이
                      // 배경에 묻혀 테두리를 준다(PS-UI-12·PS-UI-13).
                      child: Semantics(
                        button: true,
                        label: AppLocalizations.of(context).writeTitleToday,
                        child: Material(
                          color: AppColors.fabColor,
                          shape: CircleBorder(
                            side: AppColors.isDark
                                ? BorderSide(color: AppColors.textHint, width: 1)
                                : BorderSide.none,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _openWriteSheet,
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(Icons.add, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: AppLocalizations.of(context).communityTitle,
                    isSelected: selectedIndex == 2,
                    onTap: () => switchTab(2),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: AppLocalizations.of(context).settingsTitle,
                    isSelected: selectedIndex == 3,
                    onTap: () => switchTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 탭에 텍스트 라벨을 두지 않는 건 의도된 디자인이므로, 시각적 복구가 아니라
    // Semantics로 스크린리더에만 라벨을 전달한다. 종전엔 label을 받아놓고
    // 렌더도 Semantics 연결도 하지 않아 완전히 죽어 있었다(PS-UI-12).
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.textPrimary : AppColors.textHint,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
