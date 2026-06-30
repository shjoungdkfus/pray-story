import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'signup_step3_screen.dart';
import 'widgets/profile_form.dart';

/// 회원가입 2단계 — 프로필 작성(이름·사진·교회·성별·연령대).
/// 입력값을 모아 마지막 단계(테마 선택)로 넘긴다.
class SignupStep2Screen extends StatefulWidget {
  final String email;
  final String password;

  const SignupStep2Screen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  String _name = '';
  String? _church;
  String? _gender;
  int? _birthYear;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editName() async {
    final result = await showProfileTextSheet(
      context,
      title: '이름',
      initial: _name,
      hint: '이름을 입력해주세요',
      maxLength: 12,
    );
    if (result != null) setState(() => _name = result);
  }

  void _editPhoto() {
    _snack('프로필 사진 기능은 곧 제공될 예정이에요. 지금은 이름으로 만든 아바타가 보여요.');
  }

  Future<void> _editChurch() async {
    final result = await showProfileTextSheet(
      context,
      title: '교회',
      initial: _church,
      hint: '출석 중인 교회 (선택)',
      maxLength: 30,
    );
    if (result != null) {
      setState(() => _church = result.isEmpty ? null : result);
    }
  }

  Future<void> _editGender() async {
    final result = await showGenderSheet(context, current: _gender);
    if (result != null) setState(() => _gender = result);
  }

  Future<void> _editAge() async {
    final result = await showBirthYearSheet(context, current: _birthYear);
    if (result != null) setState(() => _birthYear = result);
  }

  void _next() {
    if (_name.trim().isEmpty) {
      _snack('이름을 입력해주세요.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupStep3Screen(
          email: widget.email,
          password: widget.password,
          name: _name.trim(),
          church: _church,
          gender: _gender,
          birthYear: _birthYear,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Text(
                    '환영합니다!\n프로필을 완성해주세요',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ProfileFormFields(
                    name: _name,
                    church: _church,
                    gender: _gender,
                    birthYear: _birthYear,
                    onTapName: _editName,
                    onTapPhoto: _editPhoto,
                    onTapChurch: _editChurch,
                    onTapGender: _editGender,
                    onTapAge: _editAge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    '다음',
                    style: GoogleFonts.gowunBatang(
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
