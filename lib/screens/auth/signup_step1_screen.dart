import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'signup_step2_screen.dart';

/// 회원가입 1단계 — 이메일 / 비밀번호 입력.
/// 실제 계정 생성은 마지막 단계(Step3)에서 한 번에 처리하므로
/// 여기서는 형식 검증만 하고 입력값을 다음 단계로 넘긴다.
class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _next() {
    final l = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailValid) {
      _snack(l.errEmailFormat);
      return;
    }
    if (password.length < 6) {
      _snack(l.errPasswordMin);
      return;
    }
    if (password != confirm) {
      _snack(l.errPasswordMismatch);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupStep2Screen(email: email, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
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
                    l.signup1Title,
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.signup1Subtitle,
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textHint,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _label(l.labelEmail),
                  _field(_emailController, l.hintEmailExample, false,
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 22),
                  _label(l.labelPassword),
                  _field(_passwordController, l.hintPasswordMin, _obscure,
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
                  const SizedBox(height: 22),
                  _label(l.labelPasswordConfirm),
                  _field(_confirmController, l.hintPasswordAgain, _obscure),
                ],
              ),
            ),
            _bottomButton(l.buttonNext),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );

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

  Widget _bottomButton(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
