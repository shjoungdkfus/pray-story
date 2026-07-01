import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../auth/widgets/profile_form.dart';

/// 프로필 수정 — 회원가입 Step2와 같은 카드형 폼을 공유한다.
class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  const ProfileEditScreen({super.key, this.profile});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late String _name;
  late String? _church;
  late String? _gender;
  late int? _birthYear;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.profile?.name ?? '';
    _church = widget.profile?.church;
    _gender = widget.profile?.gender;
    _birthYear = widget.profile?.birthYear;
  }

  void _snack(String message) {
    if (!mounted) return;
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

  Future<void> _save() async {
    if (_name.trim().isEmpty) {
      _snack('이름을 입력해주세요.');
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(supabaseProvider).from('profiles').upsert({
        'id': user.id,
        'name': _name.trim(),
        'church': _church,
        'gender': _gender,
        'birth_year': _birthYear,
      });
      ref.invalidate(profileProvider);
      if (!mounted) return;
      _snack('저장되었습니다.');
      Navigator.pop(context);
    } on PostgrestException {
      _snack('저장 중 문제가 발생했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                    '원하시는 정보로\n프로필을 수정해보세요',
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  if (widget.profile?.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.profile!.email,
                      style: GoogleFonts.notoSansKr(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          '수정하기',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
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
