# 죽은 코드 아카이브 (Dead Code Archive)

> 이 파일은 **앱에서 제거됐지만 나중에 다시 쓸 수 있는** 코드·문자열의 보관소다.
> 여기 있는 것은 전부 `lib/`·`assets/`·`*.arb`에서 **이미 삭제됨**. 되살리려면 아래 원문을 그대로 복사하면 된다.
>
> - **생성일:** 2026-07-28
> - **삭제 사유(공통):** 2026-07-28 이메일/비밀번호 로그인을 완전히 제거하고 **카카오·구글 OAuth 전용**으로 전환(`7c57787`). 그 결과 이메일 가입·비밀번호 재설정 경로 전체가 도달 불가능해졌다.
> - **직전 원본 커밋:** `e18cc1e` (이 커밋의 트리에 아래 파일들의 원문이 그대로 있다 — `git show e18cc1e:<경로>`)
>
> ⚠️ **되살릴 때 주의:** 이메일 로그인을 부활시키려면 코드만으론 부족하다.
> Supabase Auth의 이메일 공급자 설정, 그리고 비밀번호 재설정은 **커스텀 SMTP(Resend 등) 연결 + 발신 도메인 인증**이 선행돼야 실사용자에게 메일이 나간다.
> (`onboarding@resend.dev`는 Resend 계정 소유자 본인에게만 발송 가능 — 2026-07-28에 직접 확인한 제약)

---

## 1. 삭제된 Dart 파일

### `lib/screens/auth/signup_step1_screen.dart`

회원가입 1단계 — 이메일/비밀번호 입력 화면

<details>
<summary>원문 펼치기 (206줄)</summary>

```dart
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
          tooltip: l.commonBack,
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
          borderSide: BorderSide(color: AppColors.accentText, width: 1.5),
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
```

</details>

### `lib/screens/auth/password_reset_screen.dart`

비밀번호 재설정 (이메일 8자리 인증코드 방식)

<details>
<summary>원문 펼치기 (446줄)</summary>

```dart
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
```

</details>

---

## 2. 삭제된 ARB 문자열 키 (44개)

`lib/l10n/app_ko.arb` / `app_en.arb` 양쪽에서 제거했다. 되살릴 땐 아래 값을 두 파일에 다시 넣고 `flutter gen-l10n`을 돌린다.

| 키 | 한국어 | English |
|---|---|---|
| `navPrayerLog` | 기도 기록 | Prayer Log |
| `navCommunity` | 커뮤니티 | Community |
| `navSettings` | 설정 | Settings |
| `hintEmail` | 이메일 | Email |
| `hintPassword` | 비밀번호 | Password |
| `loginButton` | 로그인 | Log In |
| `orDivider` | 또는 | or |
| `signupPrompt` | 처음이신가요? | New here? |
| `signupLink` | 회원가입 | Sign Up |
| `errEmptyCredentials` | 이메일과 비밀번호를 입력해주세요. | Please enter your email and password. |
| `errLoginFailed` | 이메일 또는 비밀번호를 다시 확인해주세요. | Please check your email or password. |
| `forgotPasswordLink` | 비밀번호를 잊으셨나요? | Forgot your password? |
| `signup1Title` | 반가워요!\n계정을 만들어볼까요 | Welcome!\nLet's create your account |
| `signup1Subtitle` | 로그인에 사용할 이메일과 비밀번호를 입력해주세요. | Enter the email and password you'll use to log in. |
| `labelEmail` | 이메일 | Email |
| `labelPassword` | 비밀번호 | Password |
| `labelPasswordConfirm` | 비밀번호 확인 | Confirm Password |
| `hintEmailExample` | example@email.com | example@email.com |
| `hintPasswordMin` | 6자 이상 | 6+ characters |
| `hintPasswordAgain` | 비밀번호 다시 입력 | Re-enter password |
| `errEmailFormat` | 올바른 이메일 형식을 입력해주세요. | Please enter a valid email address. |
| `errPasswordMin` | 비밀번호는 6자 이상 입력해주세요. | Password must be at least 6 characters. |
| `errPasswordMismatch` | 비밀번호가 일치하지 않습니다. | Passwords do not match. |
| `resetTitle` | 비밀번호를 재설정해요 | Reset your password |
| `resetStep1Subtitle` | 가입할 때 사용한 이메일로 인증코드를 보내드릴게요. | We'll send a verification code to the email you signed up with. |
| `resetSendCodeButton` | 인증코드 보내기 | Send code |
| `resetEmailSentNotice` | 메일을 보냈어요. 스팸함도 확인해보세요. | We sent an email. Please check your spam folder too. |
| `resetStep2Subtitle` | 받으신 8자리 코드와 새 비밀번호를 입력해주세요. | Enter the 8-digit code you received and your new password. |
| `resetStep2SentTo` | {email}로 보냈어요 | Sent to {email} |
| `labelResetCode` | 인증코드 | Verification code |
| `hintResetCode` | 8자리 숫자 | 8-digit code |
| `resetConfirmButton` | 비밀번호 변경하기 | Change password |
| `resetResendPrompt` | 코드를 못 받으셨나요? | Didn't get the code? |
| `resetResendLink` | 재전송 | Resend |
| `resetResendCooldown` | {seconds}초 후 재전송 가능 | Resend available in {seconds}s |
| `errResetCodeFormat` | 8자리 숫자를 입력해주세요. | Please enter the 8-digit code. |
| `errResetCodeInvalid` | 인증코드가 올바르지 않거나 만료됐어요. 다시 요청해주세요. | The code is invalid or expired. Please request a new one. |
| `errResetFailed` | 요청 중 문제가 발생했어요. 잠시 후 다시 시도해주세요. | Something went wrong. Please try again in a moment. |
| `errResetUpdateFailed` | 비밀번호 변경에 실패했어요. 인증코드를 다시 요청해주세요. | Failed to change your password. Please request a new code. |
| `resetSuccessNotice` | 비밀번호가 변경됐어요. 다시 로그인해주세요. | Your password has been changed. Please log in again. |
| `signup3SystemOption` | 시스템 설정 따르기 | Follow system settings |
| `recordLoadError` | 오류: {error} | Error: {error} |
| `settingsNoNamePlaceholder` | 이름을 설정해 주세요 | Set your name |
| `errAlreadyRegistered` | 이미 가입된 이메일입니다. 로그인해주세요. | This email is already registered. Please log in. |

<details>
<summary>JSON 원문 (app_ko.arb 조각)</summary>

```json
{
  "navPrayerLog": "기도 기록",
  "navCommunity": "커뮤니티",
  "navSettings": "설정",
  "hintEmail": "이메일",
  "hintPassword": "비밀번호",
  "loginButton": "로그인",
  "orDivider": "또는",
  "signupPrompt": "처음이신가요?",
  "signupLink": "회원가입",
  "errEmptyCredentials": "이메일과 비밀번호를 입력해주세요.",
  "errLoginFailed": "이메일 또는 비밀번호를 다시 확인해주세요.",
  "forgotPasswordLink": "비밀번호를 잊으셨나요?",
  "signup1Title": "반가워요!\n계정을 만들어볼까요",
  "signup1Subtitle": "로그인에 사용할 이메일과 비밀번호를 입력해주세요.",
  "labelEmail": "이메일",
  "labelPassword": "비밀번호",
  "labelPasswordConfirm": "비밀번호 확인",
  "hintEmailExample": "example@email.com",
  "hintPasswordMin": "6자 이상",
  "hintPasswordAgain": "비밀번호 다시 입력",
  "errEmailFormat": "올바른 이메일 형식을 입력해주세요.",
  "errPasswordMin": "비밀번호는 6자 이상 입력해주세요.",
  "errPasswordMismatch": "비밀번호가 일치하지 않습니다.",
  "resetTitle": "비밀번호를 재설정해요",
  "resetStep1Subtitle": "가입할 때 사용한 이메일로 인증코드를 보내드릴게요.",
  "resetSendCodeButton": "인증코드 보내기",
  "resetEmailSentNotice": "메일을 보냈어요. 스팸함도 확인해보세요.",
  "resetStep2Subtitle": "받으신 8자리 코드와 새 비밀번호를 입력해주세요.",
  "resetStep2SentTo": "{email}로 보냈어요",
  "@resetStep2SentTo": {
    "placeholders": {
      "email": {
        "type": "String"
      }
    }
  },
  "labelResetCode": "인증코드",
  "hintResetCode": "8자리 숫자",
  "resetConfirmButton": "비밀번호 변경하기",
  "resetResendPrompt": "코드를 못 받으셨나요?",
  "resetResendLink": "재전송",
  "resetResendCooldown": "{seconds}초 후 재전송 가능",
  "@resetResendCooldown": {
    "placeholders": {
      "seconds": {
        "type": "int"
      }
    }
  },
  "errResetCodeFormat": "8자리 숫자를 입력해주세요.",
  "errResetCodeInvalid": "인증코드가 올바르지 않거나 만료됐어요. 다시 요청해주세요.",
  "errResetFailed": "요청 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.",
  "errResetUpdateFailed": "비밀번호 변경에 실패했어요. 인증코드를 다시 요청해주세요.",
  "resetSuccessNotice": "비밀번호가 변경됐어요. 다시 로그인해주세요.",
  "signup3SystemOption": "시스템 설정 따르기",
  "recordLoadError": "오류: {error}",
  "@recordLoadError": {
    "placeholders": {
      "error": {
        "type": "Object"
      }
    }
  },
  "settingsNoNamePlaceholder": "이름을 설정해 주세요"
}
```

</details>

<details>
<summary>JSON 원문 (app_en.arb 조각)</summary>

```json
{
  "navPrayerLog": "Prayer Log",
  "navCommunity": "Community",
  "navSettings": "Settings",
  "hintEmail": "Email",
  "hintPassword": "Password",
  "loginButton": "Log In",
  "orDivider": "or",
  "signupPrompt": "New here?",
  "signupLink": "Sign Up",
  "errEmptyCredentials": "Please enter your email and password.",
  "errLoginFailed": "Please check your email or password.",
  "forgotPasswordLink": "Forgot your password?",
  "signup1Title": "Welcome!\nLet's create your account",
  "signup1Subtitle": "Enter the email and password you'll use to log in.",
  "labelEmail": "Email",
  "labelPassword": "Password",
  "labelPasswordConfirm": "Confirm Password",
  "hintEmailExample": "example@email.com",
  "hintPasswordMin": "6+ characters",
  "hintPasswordAgain": "Re-enter password",
  "errEmailFormat": "Please enter a valid email address.",
  "errPasswordMin": "Password must be at least 6 characters.",
  "errPasswordMismatch": "Passwords do not match.",
  "resetTitle": "Reset your password",
  "resetStep1Subtitle": "We'll send a verification code to the email you signed up with.",
  "resetSendCodeButton": "Send code",
  "resetEmailSentNotice": "We sent an email. Please check your spam folder too.",
  "resetStep2Subtitle": "Enter the 8-digit code you received and your new password.",
  "resetStep2SentTo": "Sent to {email}",
  "@resetStep2SentTo": {
    "placeholders": {
      "email": {
        "type": "String"
      }
    }
  },
  "labelResetCode": "Verification code",
  "hintResetCode": "8-digit code",
  "resetConfirmButton": "Change password",
  "resetResendPrompt": "Didn't get the code?",
  "resetResendLink": "Resend",
  "resetResendCooldown": "Resend available in {seconds}s",
  "@resetResendCooldown": {
    "placeholders": {
      "seconds": {
        "type": "int"
      }
    }
  },
  "errResetCodeFormat": "Please enter the 8-digit code.",
  "errResetCodeInvalid": "The code is invalid or expired. Please request a new one.",
  "errResetFailed": "Something went wrong. Please try again in a moment.",
  "errResetUpdateFailed": "Failed to change your password. Please request a new code.",
  "resetSuccessNotice": "Your password has been changed. Please log in again.",
  "signup3SystemOption": "Follow system settings",
  "recordLoadError": "Error: {error}",
  "@recordLoadError": {
    "placeholders": {
      "error": {
        "type": "Object"
      }
    }
  },
  "settingsNoNamePlaceholder": "Set your name"
}
```

</details>


---

## 3. 제거된 죽은 분기 (live 파일 안에 남아있던 것)

파일 자체는 살아있지만, **절대 실행될 수 없는 코드 경로**라 잘라냈다.
전부 "이메일 가입 경로가 있던 시절"의 잔재다.

### 3-1. `signup_step3_screen.dart` — `signUp()` 호출 분기

`SignupStep3Screen`의 유일한 도달 경로가 OAuth 온보딩(`main.dart` `_RootGate`)뿐이라
`email`/`password`는 항상 `null`이었다. 즉 아래 `if` 참이 되는 경우가 없었다.

```dart
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
```

**→ 대체:** `final userId = supabase.auth.currentUser?.id;` 한 줄.

### 3-2. `signup_step3_screen.dart` — `on AuthException` catch 블록

`signUp()`이 사라지면서 `try` 안에서 `AuthException`을 던질 수 있는 호출이 하나도
없어졌다(프로필 저장 실패는 `PostgrestException`). PS-UI-18 대응으로 넣었던
"이메일 중복 시 1단계로 되돌리기" 로직도 1단계 화면이 삭제돼 함께 무의미해졌다.

```dart
} on AuthException catch (e) {
  final alreadyRegistered = e.code == 'user_already_exists';
  _snack(alreadyRegistered ? l.errAlreadyRegistered : l.errSignupFailed);
  // 이메일 중복은 1단계 입력값 문제인데 종전엔 3단계에 머물러, 사용자가
  // 뒤로 두 번 눌러 되돌아가야 했다(PS-UI-18). 이메일 입력 화면까지 돌려보낸다.
  // 스택은 로그인 → 1단계 → 2단계 → 3단계 순이므로 두 번 pop하면 1단계로 돌아간다.
  if (alreadyRegistered && mounted) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(); // 3단계 닫기
    if (navigator.canPop()) navigator.pop(); // 2단계 닫기
  }
} on PostgrestException {
```

**→ 대체:** 블록 통째로 삭제. 예상 못 한 `AuthException`은 맨 끝 `catch (_)`가
`errSignupFailed`로 안내하므로 조용히 실패하지 않는다.

### 3-3. `SignupStep2Screen` / `SignupStep3Screen`의 `email`·`password` 파라미터

위 분기가 사라지면서 두 화면 모두 쓰지 않는 값이 됐다. 생성자에서 제거했고,
`main.dart:134`의 호출부도 `const SignupStep2Screen()`으로 줄였다.

```dart
// 삭제 전
final String? email;
final String? password;
// main.dart
return const SignupStep2Screen(email: null, password: null);
```

### 3-4. `OnboardingExitGuard`의 `active` 스위치

`profile_form.dart`. `active: widget.email == null && widget.password == null`으로
호출되던 것이 **양쪽 호출부 모두 항상 `true`**가 됐다.

```dart
class OnboardingExitGuard extends StatelessWidget {
  final bool active;   // ← 제거
  ...
  return PopScope(
    canPop: !active,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop || !active) return;
      _confirmExit(context);
    },
    child: child,
  );
```

**→ 대체:** `canPop: false` 고정, `if (didPop) return;`.
되살릴 일이 생기면(가입 경로가 둘 이상으로 늘어나면) 위 형태로 복원하면 된다.

---

## 4. 삭제된 미사용 자산

| 경로 | 사유 |
|---|---|
| `assets/splash/splash_A_burgundy_bg.png` | 2026-06-24에 올린 스플래시 **시안** 2종 중 A안. 최종 스플래시는 `flutter_native_splash`가 `assets/icon/splash_logo.png`로 생성하므로 어느 쪽도 참조되지 않는다. |
| `assets/splash/splash_B_cream_bg.png` | 위와 동일(B안). |

> 참고: `pubspec.yaml`의 `flutter:` 블록에는 `assets:` 선언이 아예 없다.
> 즉 이 두 파일은 앱 번들에 포함된 적도 없고, 빌드 설정(`flutter_launcher_icons`,
> `flutter_native_splash`)도 참조하지 않았다.

---

## 5. 되살리지 않은 채 남겨둔 것 (참고)

| 항목 | 상태 |
|---|---|
| `docs/다국어_지원_상세보고서.md` | **내용이 부정확한 문서.** 2026-07-17에 "레이어2 앱 내부 다국어 미구현"이라는 전제가 틀린 것으로 확인됨(실제로는 2026-07-04에 완료). 삭제하지 않고 뒀으나 **참고 시 코드를 먼저 확인할 것.** |
| `docs/SPEC.md` FR-016 (비밀번호 재설정) | 기능이 제거됐으므로 명세도 폐기 표시함. |
| Supabase 커스텀 SMTP(Resend) 연동 | 서버 쪽 설정은 그대로 살아있다. 앱에서 쓰는 곳이 없어졌을 뿐이다. 이메일 기능을 되살릴 때 재사용 가능. |
