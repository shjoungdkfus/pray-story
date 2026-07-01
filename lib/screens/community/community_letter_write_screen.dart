import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/community_provider.dart';

class CommunityLetterWriteScreen extends ConsumerStatefulWidget {
  final String? groupId;
  final String? groupName;
  final String? recipientName;

  const CommunityLetterWriteScreen({
    super.key,
    this.groupId,
    this.groupName,
    this.recipientName,
  });

  @override
  ConsumerState<CommunityLetterWriteScreen> createState() =>
      _CommunityLetterWriteScreenState();
}

class _CommunityLetterWriteScreenState
    extends ConsumerState<CommunityLetterWriteScreen> {
  final _contentController = TextEditingController();
  late String _visibility;
  String? _selectedGroupId;
  String? _selectedGroupName;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _visibility = 'group';
      _selectedGroupId = widget.groupId;
      _selectedGroupName = widget.groupName;
    } else {
      _visibility = 'community';
    }
    if (widget.recipientName != null) {
      _contentController.text = 'Dear God,\n';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      await postCommunityLetter(
        ref,
        content: content,
        visibility: _visibility,
        groupId: _visibility == 'group' ? _selectedGroupId : null,
        recipientName: widget.recipientName,
      );
      if (mounted) {
        ref.invalidate(communityLettersProvider);
        if (_selectedGroupId != null) {
          ref.invalidate(groupLettersProvider(_selectedGroupId!));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기도 편지가 전달되었습니다')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String get _visibilityLabel {
    if (_visibility == 'private') return '나만보기';
    if (_visibility == 'group') return _selectedGroupName ?? '그룹';
    return '커뮤니티';
  }

  void _showVisibilityPicker() {
    final groups = ref.read(myGroupsProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, size: 20),
              title: Text('나만보기', style: GoogleFonts.notoSansKr()),
              onTap: () {
                setState(() {
                  _visibility = 'private';
                  _selectedGroupId = null;
                  _selectedGroupName = null;
                });
                Navigator.pop(context);
              },
            ),
            ...groups.map((g) => ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                    child: Text(
                      g.name.isNotEmpty ? g.name.characters.first : '?',
                      style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                  title: Text(g.name, style: GoogleFonts.notoSansKr()),
                  onTap: () {
                    setState(() {
                      _visibility = 'group';
                      _selectedGroupId = g.id;
                      _selectedGroupName = g.name;
                    });
                    Navigator.pop(context);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.public, size: 20),
              title: Text('커뮤니티', style: GoogleFonts.notoSansKr()),
              onTap: () {
                setState(() {
                  _visibility = 'community';
                  _selectedGroupId = null;
                  _selectedGroupName = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('M월 d일 EEEE', 'ko').format(now);

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
          dateStr,
          style: GoogleFonts.notoSansKr(color: AppColors.textPrimary, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _sending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                  )
                : Icon(Icons.arrow_upward, color: AppColors.textPrimary),
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 공개 범위 + 옵션 칩
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showVisibilityPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_visibility == 'private')
                            Icon(Icons.lock_outline, size: 14, color: AppColors.textPrimary),
                          if (_visibility == 'private') const SizedBox(width: 4),
                          Text(
                            _visibilityLabel,
                            style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more, size: 16, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 수신자 표시
          if (widget.recipientName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.recipientName} 위한 편지',
                    style: GoogleFonts.notoSansKr(fontSize: 13, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          // 본문
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.8,
                ),
                decoration: InputDecoration(
                  hintText: 'Dear God,',
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
