import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/supabase/supabase_config.dart';
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
    final isDark = switch (mode) {
      AppThemeMode.dark => true,
      AppThemeMode.light => false,
      AppThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    return MaterialApp(
      title: 'PrayStory',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      theme: _buildTheme(isDark),
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  Widget _loadingScreen() => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
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
            return AnimatedOpacity(
              opacity: selectedIndex == i ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: selectedIndex != i,
                child: _screens[i],
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
                    label: '기도 기록',
                    isSelected: selectedIndex == 1,
                    onTap: () => switchTab(1),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _openWriteSheet,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.fabColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: '커뮤니티',
                    isSelected: selectedIndex == 2,
                    onTap: () => switchTab(2),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: '설정',
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
    return Expanded(
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
    );
  }
}
