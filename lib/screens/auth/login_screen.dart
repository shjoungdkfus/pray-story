import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'signup_step1_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack(l.errEmptyCredentials);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(supabaseProvider)
          .auth
          .signInWithPassword(email: email, password: password);
      // 로그인 성공 시 authState 스트림이 갱신되어 _RootGate가 메인으로 전환한다.
    } on AuthException {
      _snack(l.errLoginFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      await ref.read(supabaseProvider).auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
      // 로그인 성공 시 authState 스트림이 갱신되어 _RootGate가 전환한다.
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _snack(l.errGoogleFailed);
      }
    } on AuthException {
      _snack(l.errGoogleFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithKakao() async {
    final l = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await ref.read(supabaseProvider).auth.signInWithOAuth(
            OAuthProvider.kakao,
            redirectTo: 'com.praystory://login-callback',
            authScreenLaunchMode: LaunchMode.externalApplication,
          );
      // 브라우저에서 로그인 완료 후 딥링크로 앱에 복귀하면
      // authState 스트림이 갱신되어 _RootGate가 전환한다.
    } on AuthException {
      _snack(l.errKakaoFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                    fontSize: 34,
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
                _field(_emailController, l.hintEmail, false,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_passwordController, l.hintPassword, _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
                const SizedBox(height: 24),
                _primaryButton(
                  label: l.loginButton,
                  onPressed: _isLoading ? null : _login,
                  loading: _isLoading,
                ),
                const SizedBox(height: 20),
                _orDivider(l.orDivider),
                const SizedBox(height: 20),
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
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l.signupPrompt,
                      style: GoogleFonts.notoSansKr(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignupStep1Screen(),
                                ),
                              ),
                      child: Text(
                        l.signupLink,
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    bool obscure, {
    Widget? suffix,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: GoogleFonts.notoSansKr(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.notoSansKr(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.card,
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _orDivider(String orLabel) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            orLabel,
            style: GoogleFonts.notoSansKr(
              color: AppColors.textHint,
              fontSize: 12.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }

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
