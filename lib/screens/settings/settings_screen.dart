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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openEditProfile(BuildContext context, ProfileModel? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          '설정',
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '나의 계정',
                      style: GoogleFonts.gowunBatang(
                        color: AppColors.textHint,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openEditProfile(context, profile.valueOrNull),
                      child: Text(
                        '수정',
                        style: GoogleFonts.gowunBatang(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                profile.when(
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (p) => Column(
                    children: [
                      _ProfileRow(label: '이름', value: p?.name.isNotEmpty == true ? p!.name : '-'),
                      const SizedBox(height: 12),
                      _ProfileRow(
                        label: '생년월일',
                        value: p?.birthdate != null
                            ? DateFormat('yyyy년 M월 d일').format(p!.birthdate!)
                            : '-',
                      ),
                      const SizedBox(height: 12),
                      _ProfileRow(label: '성별', value: p?.gender ?? '-'),
                      const SizedBox(height: 12),
                      _ProfileRow(label: '이메일', value: p?.email ?? '-'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            tileColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              '로그아웃',
              style: GoogleFonts.gowunBatang(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.logout, color: AppColors.accent),
            onTap: () async {
              await ref.read(supabaseProvider).auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  const _EditProfileSheet({this.profile});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
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
                  child: Text('취소', style: GoogleFonts.gowunBatang(color: AppColors.textHint, fontSize: 15)),
                ),
                Text('생년월일', style: GoogleFonts.gowunBatang(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() => _birthdate = picked);
                    Navigator.pop(ctx);
                  },
                  child: Text('확인', style: GoogleFonts.gowunBatang(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.bold)),
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
        'birthdate': _birthdate != null ? DateFormat('yyyy-MM-dd').format(_birthdate!) : null,
        'gender': _gender,
      });
      ref.invalidate(profileProvider);
      if (!mounted) return;
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

  Widget _genderButton(String g) {
    final selected = _gender == g;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = g),
        child: Container(
          margin: EdgeInsets.only(right: g == '남' ? 6 : 0, left: g == '여' ? 6 : 0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.background,
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로필 수정',
              style: GoogleFonts.gowunBatang(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: GoogleFonts.gowunBatang(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '이름',
                hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickBirthdate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _birthdate != null ? DateFormat('yyyy년 M월 d일').format(_birthdate!) : '생년월일',
                  style: GoogleFonts.gowunBatang(
                    color: _birthdate != null ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [_genderButton('남'), _genderButton('여')]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        '저장하기',
                        style: GoogleFonts.gowunBatang(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: GoogleFonts.gowunBatang(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.gowunBatang(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
