import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  DateTime? _birthdate;
  String? _gender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _pickBirthdate() {
    var picked = _birthdate ?? DateTime(1995, 1, 1);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '취소',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textHint,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '생년월일',
                  style: GoogleFonts.gowunBatang(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _birthdate = picked);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    '확인',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 216,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: picked,
              maximumDate: DateTime.now(),
              minimumDate: DateTime(1920),
              backgroundColor: AppColors.card,
              onDateTimeChanged: (d) => picked = d,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseProvider);
      if (_isLogin) {
        await supabase.auth.signInWithPassword(email: email, password: password);
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (response.user != null) {
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'name': _nameController.text.trim(),
            'birthdate': _birthdate != null
                ? DateFormat('yyyy-MM-dd').format(_birthdate!)
                : null,
            'gender': _gender,
          });
        }
      }
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 또는 비밀번호를 다시 확인해주세요.')),
      );
    } on PostgrestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정은 만들어졌습니다. 앱에서 프로필을 완성해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 48),
                Text(
                  'PrayStory',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '하나님이 오늘 나를 통해 써 내려가시는 이야기',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 13,
                    color: AppColors.textHint,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!_isLogin) ...[
                  _buildTextField(_nameController, '이름', false),
                  const SizedBox(height: 12),
                  _buildBirthdateField(),
                  const SizedBox(height: 12),
                  _buildGenderSelector(),
                  const SizedBox(height: 12),
                ],
                _buildTextField(_emailController, '이메일', false),
                const SizedBox(height: 12),
                _buildTextField(_passwordController, '비밀번호', true),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? '성경책 열기' : 'PrayStory 시작하기',
                            style: GoogleFonts.gowunBatang(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _nameController.clear();
                    _birthdate = null;
                    _gender = null;
                  }),
                  child: Text(
                    _isLogin ? '처음이신가요? PrayStory 만들기' : '이미 계정이 있으신가요? 로그인',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.gowunBatang(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildBirthdateField() {
    return GestureDetector(
      onTap: _pickBirthdate,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _birthdate != null
              ? DateFormat('yyyy년 M월 d일').format(_birthdate!)
              : '생년월일',
          style: GoogleFonts.gowunBatang(
            color: _birthdate != null
                ? AppColors.textPrimary
                : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['남', '여'].map((g) {
        final selected = _gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              margin: EdgeInsets.only(right: g == '남' ? 6 : 0, left: g == '여' ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                g,
                textAlign: TextAlign.center,
                style: GoogleFonts.gowunBatang(
                  color: selected ? Colors.white : AppColors.textHint,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
