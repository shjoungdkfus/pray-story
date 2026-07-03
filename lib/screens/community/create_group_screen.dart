import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/community_provider.dart';
import 'join_group_screen.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      await createGroup(ref, name: name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.createGroupSuccess(name))),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.commonError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l.createGroupTitle,
          style: GoogleFonts.notoSansKr(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.group_add_outlined, color: AppColors.accent, size: 28),
            const SizedBox(height: 16),
            Text(
              l.createGroupHeading,
              style: GoogleFonts.notoSansKr(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.createGroupDesc,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.textHint,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              l.createGroupNameLabel,
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l.createGroupNameHint,
                hintStyle: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(l.createGroupTitle, style: GoogleFonts.notoSansKr(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                  );
                },
                child: Text(
                  l.createGroupJoinLink,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: AppColors.textHint,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textHint,
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
