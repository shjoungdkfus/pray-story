import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';

/// 회원가입 3단계 — 화면 테마 선택 후 실제 계정 생성.
/// 여기서 signUp + profiles insert + 테마 저장을 한 번에 처리한다.
/// (앞 단계에서 미리 가입하지 않는 이유: 가입 즉시 세션이 생기면
///  _RootGate가 메인 화면으로 전환되어 온보딩 스택이 사라지기 때문)
class SignupStep3Screen extends ConsumerStatefulWidget {
  final String? email;
  final String? password;
  final String name;
  final String? church;
  final String? gender;
  final int? birthYear;

  const SignupStep3Screen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.church,
    required this.gender,
    required this.birthYear,
  });

  @override
  ConsumerState<SignupStep3Screen> createState() => _SignupStep3ScreenState();
}

class _SignupStep3ScreenState extends ConsumerState<SignupStep3Screen> {
  AppThemeMode _selected = AppThemeMode.light;
  bool _isLoading = false;

  bool _isDarkFor(AppThemeMode mode) => switch (mode) {
        AppThemeMode.dark => true,
        AppThemeMode.light => false,
        AppThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark,
      };

  @override
  void dispose() {
    // 미리보기로 바꿔둔 전역 팔레트를 실제 저장된 테마로 되돌린다.
    AppColors.setMode(_isDarkFor(ref.read(themeModeProvider)));
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseProvider);
      String? userId;
      if (widget.email != null && widget.password != null) {
        // 이메일 회원가입 경로 — 계정을 새로 만든다.
        final response = await supabase.auth.signUp(
          email: widget.email!,
          password: widget.password!,
        );
        userId = response.user?.id;
      } else {
        // 카카오/구글 로그인 직후 온보딩 경로 — 이미 세션이 있으므로 프로필만 저장한다.
        userId = supabase.auth.currentUser?.id;
      }
      if (userId != null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'name': widget.name,
          'church': widget.church,
          'gender': widget.gender,
          'birth_year': widget.birthYear,
        });
        // 카카오/구글 온보딩 경로는 세션이 이미 있어 authState가 바뀌지 않으므로
        // profileProvider를 직접 무효화해야 _RootGate가 메인으로 전환된다.
        ref.invalidate(profileProvider);
      }
      // 테마 저장 — 세션 갱신(또는 profiles 갱신)으로 _RootGate가 메인으로 전환된다.
      await ref.read(themeModeProvider.notifier).setMode(_selected);
      // _RootGate는 화면 맨 아래(루트) 라우트라, 위에 쌓인 온보딩 스택
      // (로그인→가입1~3)을 걷어내야 메인 화면이 실제로 드러난다.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      final message = e.code == 'user_already_exists'
          ? '이미 가입된 이메일입니다. 로그인해주세요.'
          : '가입 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.';
      _snack(message);
    } on PostgrestException {
      // 계정은 생성됐지만 프로필 저장이 실패한 경우.
      await ref.read(themeModeProvider.notifier).setMode(_selected);
      _snack('계정이 만들어졌어요. 프로필은 설정에서 완성할 수 있어요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 카드 선택에 맞춰 이 화면 전체를 실시간으로 미리보기 전환한다.
    AppColors.setMode(_isDarkFor(_selected));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: _isLoading ? null : () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                children: [
                  Text(
                    '거의 다 왔어요!\n화면 테마를 골라주세요',
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '나중에 설정에서 언제든 바꿀 수 있어요.',
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textHint,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeCard(
                          label: '라이트',
                          isDark: false,
                          selected: _selected == AppThemeMode.light,
                          onTap: () =>
                              setState(() => _selected = AppThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ThemeCard(
                          label: '다크',
                          isDark: true,
                          selected: _selected == AppThemeMode.dark,
                          onTap: () =>
                              setState(() => _selected = AppThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SystemOption(
                    selected: _selected == AppThemeMode.system,
                    onTap: () =>
                        setState(() => _selected = AppThemeMode.system),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'PrayStory 시작하기',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
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
}

/// 라이트/다크 미리보기 카드.
class _ThemeCard extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 내부는 실제 팔레트 느낌으로 고정 색을 쓴다.
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8F4EC);
    final fg = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF150A02);
    final sub = isDark ? const Color(0xFF7D8590) : const Color(0xFF9C8A7A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 132,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sub.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 6,
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      color: sub.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 5,
                    decoration: BoxDecoration(
                      color: sub.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B1A0F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle, color: AppColors.accent, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// "시스템 설정 따르기" 옵션.
class _SystemOption extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SystemOption({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.divider.withOpacity(0.6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.brightness_auto_outlined,
                  color: selected ? AppColors.accent : AppColors.textHint,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '시스템 설정 따르기',
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
