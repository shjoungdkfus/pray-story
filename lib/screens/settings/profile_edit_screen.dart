import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  const ProfileEditScreen({super.key, this.profile});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _nameController;
  DateTime? _birthdate;
  String? _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _birthdate = widget.profile?.birthdate;
    _gender = widget.profile?.gender;
  }

  @override
  void dispose() {
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
                  child: Text('취소',
                      style: GoogleFonts.gowunBatang(
                          color: AppColors.textHint, fontSize: 15)),
                ),
                Text('생년월일',
                    style: GoogleFonts.gowunBatang(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() => _birthdate = picked);
                    Navigator.pop(ctx);
                  },
                  child: Text('확인',
                      style: GoogleFonts.gowunBatang(
                          color: AppColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(supabaseProvider).from('profiles').upsert({
        'id': user.id,
        'name': _nameController.text.trim(),
        'birthdate': _birthdate != null
            ? DateFormat('yyyy-MM-dd').format(_birthdate!)
            : null,
        'gender': _gender,
      });
      ref.invalidate(profileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
      Navigator.pop(context);
    } on PostgrestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(
          text,
          style: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.7)),
      );

  Widget _genderButton(String g) {
    final selected = _gender == g;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = g),
        child: Container(
          margin: EdgeInsets.only(right: g == '남' ? 6 : 0, left: g == '여' ? 6 : 0),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : AppColors.divider.withOpacity(0.7),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim().characters.first
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '내 정보',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: GoogleFonts.gowunBatang(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              widget.profile?.email ?? '',
              style: GoogleFonts.gowunBatang(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _fieldLabel('이름'),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.gowunBatang(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '이름',
              hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.card,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.divider.withOpacity(0.7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
          const SizedBox(height: 22),
          _fieldLabel('생년월일'),
          GestureDetector(
            onTap: _pickBirthdate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: _boxDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthdate != null
                          ? DateFormat('yyyy년 M월 d일').format(_birthdate!)
                          : '생년월일을 선택해 주세요',
                      style: GoogleFonts.gowunBatang(
                        color: _birthdate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textHint, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _fieldLabel('성별'),
          Row(children: [_genderButton('남'), _genderButton('여')]),
          const SizedBox(height: 36),
          SizedBox(
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
                      '저장하기',
                      style: GoogleFonts.gowunBatang(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
