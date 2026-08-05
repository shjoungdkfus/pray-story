import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loginWithGoogle() async {
    final l = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        _snack(l.errGoogleFailed);
        return;
      }
      await ref
          .read(supabaseProvider)
          .auth
          .signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
      // 로그인 성공 시 authState 스트림이 갱신되어 _RootGate가 전환한다.
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _snack(l.errGoogleFailed);
      }
    } on AuthException {
      _snack(l.errGoogleFailed);
    } catch (e) {
      debugPrint('google signIn failed: $e');
      _snack(l.errNetwork);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithKakao() async {
    final l = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await ref
          .read(supabaseProvider)
          .auth
          .signInWithOAuth(
            OAuthProvider.kakao,
            redirectTo: 'com.praystory://login-callback',
            authScreenLaunchMode: LaunchMode.externalApplication,
          );
      // 브라우저에서 로그인 완료 후 딥링크로 앱에 복귀하면
      // authState 스트림이 갱신되어 _RootGate가 전환한다.
    } on AuthException {
      _snack(l.errKakaoFailed);
    } catch (e) {
      debugPrint('kakao signIn failed: $e');
      _snack(l.errNetwork);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: _backdropGradient()),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'PrayStory',
                    style: GoogleFonts.gowunBatang(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.loginTagline,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      color: AppColors.textHint,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 44),
                  _socialButton(
                    label: l.kakaoStart,
                    background: const Color(0xFFFEE500),
                    foreground: const Color(0xFF191600),
                    icon: Icons.chat_bubble_rounded,
                    onPressed: _isLoading ? null : _loginWithKakao,
                  ),
                  const SizedBox(height: 12),
                  _socialButton(
                    label: l.googleStart,
                    background: Colors.white,
                    foreground: const Color(0xFF1F1F1F),
                    icon: Icons.g_mobiledata_rounded,
                    iconSize: 30,
                    border: true,
                    onPressed: _isLoading ? null : _loginWithGoogle,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 화면 가장자리를 파스텔로 감싸고 가운데(제목·문구·로그인 버튼)는
  /// 배경색 그대로 비워 둔다. 본문 대비에 영향을 주지 않도록 가장 진한
  /// 가장자리도 배경색과 크게 벌어지지 않는 범위로 제한한다.
  Gradient _backdropGradient() => RadialGradient(
    center: const Alignment(0, -0.08),
    radius: 1.0,
    colors: AppColors.isDark
        ? [
            AppColors.background,
            const Color(0xFF232220),
            const Color(0xFF3E3A30),
            const Color(0xFF564F3F),
          ]
        : [
            AppColors.background,
            const Color(0xFFF3F0EA),
            const Color(0xFFE0D9C7),
            const Color(0xFFCBC1A9),
          ],
    stops: const [0.0, 0.5, 0.78, 1.0],
  );

  Widget _socialButton({
    required String label,
    required Color background,
    required Color foreground,
    required IconData icon,
    required VoidCallback? onPressed,
    double iconSize = 20,
    bool border = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border
                ? BorderSide(color: AppColors.divider.withOpacity(0.8))
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: foreground),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
