import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/community_models.dart';
import '../../providers/community_provider.dart';

class NoticeWriteScreen extends ConsumerStatefulWidget {
  final CommunityGroup group;
  const NoticeWriteScreen({super.key, required this.group});

  @override
  ConsumerState<NoticeWriteScreen> createState() => _NoticeWriteScreenState();
}

class _NoticeWriteScreenState extends ConsumerState<NoticeWriteScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    final l = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await postNotice(ref, widget.group.id, content);
      if (mounted) {
        ref.invalidate(groupNoticesProvider(widget.group.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.noticePosted)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.commonError(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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
        title: Text(l.noticeWriteTitle, style: GoogleFonts.notoSansKr(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _sending ? null : _send,
            child: _sending
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                : Text(l.buttonPost, style: GoogleFonts.notoSansKr(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: Text(l.noticeBadge, style: GoogleFonts.notoSansKr(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(l.noticeDeliveredTo(widget.group.name), style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                autofocus: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.notoSansKr(fontSize: 15, color: AppColors.textPrimary, height: 1.8),
                decoration: InputDecoration(
                  hintText: l.noticeHint,
                  hintStyle: GoogleFonts.notoSansKr(color: AppColors.textHint),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
