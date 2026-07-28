import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

enum _ResetStep { requestEmail, verifyAndReset }

/// 비밀번호 재설정 — 이메일로 8자리 인증코드를 받아 새 비밀번호로 교체한다.
/// (Supabase 프로젝트의 OTP 길이 설정이 8자리라 실기기 검증으로 확인됨 — 일반적인
/// 6자리 관행과 다르니 향후 프로젝트 OTP 설정을 바꾸면 이 값도 같이 바꿔야 한다.)
/// (딥링크 대신 코드 방식을 쓰는 이유: PKCE 딥링크는 요청한 기기에서만
/// 열어야 동작하지만, 코드는 기기 제약이 없어 실패 지점이 훨씬 적다.)
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  _ResetStep _step = _ResetStep.requestEmail;
  String _sentToEmail = '';
  Timer? _cooldownTimer;
  int _cooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _requestCode({required bool isResend}) async {
    final l = AppLocalizations.of(context);
    final email =
        isResend ? _sentToEmail : _emailController.text.trim();

    if (!isResend) {
      final emailValid =
          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
      if (!emailValid) {
        _snack(l.errEmailFormat);
        return;
      }
    }
    if (_isLoading || (isResend && _cooldown > 0)) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(supabaseProvider).auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _sentToEmail = email;
        _step = _ResetStep.verifyAndReset;
      });
      _snack(l.resetEmailSentNotice);
      _startCooldown();
    } on AuthException {
      _snack(l.errResetFailed);
    } catch (_) {
      _snack(l.errNetwork);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmReset() async {
    final l = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (code.length != 8) {
      _snack(l.errResetCodeFormat);
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

    setState(() => _isLoading = true);
    final supabase = ref.read(supabaseProvider);

    try {
      await supabase.auth.verifyOTP(
        email: _sentToEmail,
        token: code,
        type: OtpType.recovery,
      );
    } on AuthException {
      if (mounted) _snack(l.errResetCodeInvalid);
      if (mounted) setState(() => _isLoading = false);
      return;
    } catch (_) {
      if (mounted) _snack(l.errNetwork);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // 코드는 위 verifyOTP에서 이미 1회성으로 소모됐다. 여기서부터 실패하면
    // 재시도가 아니라 처음부터 새 코드를 다시 받아야 한다.
    try {
      await supabase.auth.updateUser(UserAttributes(password: password));
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      _snack(l.resetSuccessNotice);
    } catch (_) {
      await supabase.auth.signOut();
      if (!mounted) return;
      setState(() {
        _step = _ResetStep.requestEmail;
        _codeController.clear();
      });
      _snack(l.errResetUpdateFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: _step == _ResetStep.requestEmail,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() => _step = _ResetStep.requestEmail);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: AppColors.textPrimary,
            tooltip: l.commonBack,
            onPressed: _isLoading
                ? null
                : () {
                    if (_step == _ResetStep.verifyAndReset) {
                      setState(() => _step = _ResetStep.requestEmail);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
          ),
        ),
        body: SafeArea(
          child: _step == _ResetStep.requestEmail
              ? _buildRequestStep(l)
              : _buildVerifyStep(l),
        ),
      ),
    );
  }

  Widget _buildRequestStep(AppLocalizations l) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            children: [
              Text(
                l.resetTitle,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.resetStep1Subtitle,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 36),
              _label(l.labelEmail),
              _field(_emailController, l.hintEmailExample, false,
                  keyboard: TextInputType.emailAddress),
            ],
          ),
        ),
        _bottomButton(
          l.resetSendCodeButton,
          onPressed: () => _requestCode(isResend: false),
        ),
      ],
    );
  }

  Widget _buildVerifyStep(AppLocalizations l) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            children: [
              Text(
                l.resetTitle,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.resetStep2Subtitle,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.resetStep2SentTo(_sentToEmail),
                style: GoogleFonts.notoSansKr(
                  color: AppColors.accentText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              _label(l.labelResetCode),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                style: GoogleFonts.notoSansKr(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: l.hintResetCode,
                  hintStyle: GoogleFonts.notoSansKr(
                    color: AppColors.textHint,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.divider.withOpacity(0.7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.accentText, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _resendButton(l),
                ),
              ),
              const SizedBox(height: 18),
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
        _bottomButton(l.resetConfirmButton, onPressed: _confirmReset),
      ],
    );
  }

  Widget _resendButton(AppLocalizations l) {
    if (_cooldown > 0) {
      return Text(
        l.resetResendCooldown(_cooldown),
        style: GoogleFonts.notoSansKr(color: AppColors.textHint, fontSize: 12.5),
      );
    }
    return GestureDetector(
      onTap: _isLoading ? null : () => _requestCode(isResend: true),
      child: Text(
        '${l.resetResendPrompt} ${l.resetResendLink}',
        style: GoogleFonts.notoSansKr(
          color: AppColors.accentText,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
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
          borderSide: BorderSide(color: AppColors.accentText, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _bottomButton(String label, {required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
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
      ),
    );
  }
}
