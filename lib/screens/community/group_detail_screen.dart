import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/community_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import 'community_letter_write_screen.dart';
import 'invite_group_screen.dart';
import 'notice_write_screen.dart';
import 'widgets/group_icon_picker.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final CommunityGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  late CommunityGroup _group;
  int _tab = 0; // 0=공지, 1=서신, 2=멤버
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _pageController = PageController(initialPage: _tab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOwner => ref.read(currentUserProvider)?.id == _group.ownerId;

  void _refresh() {
    ref.invalidate(groupNoticesProvider(_group.id));
    ref.invalidate(groupLettersProvider(_group.id));
    ref.invalidate(groupMembersProvider(_group.id));
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(groupNoticesProvider(_group.id));
    final letters = ref.watch(groupLettersProvider(_group.id));
    final members = ref.watch(groupMembersProvider(_group.id));

    final noticeCount = notices.valueOrNull?.length ?? 0;
    final letterCount = letters.valueOrNull?.length ?? 0;
    final memberCount = members.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(memberCount),
            _buildTabs(noticeCount, letterCount, memberCount),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _tab = i),
                children: [
                  _NoticeList(group: _group, isOwner: _isOwner),
                  _LetterList(group: _group),
                  _MemberList(group: _group, isOwner: _isOwner),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── 헤더 ────────────────────────────────────────────────────────────────────
  Widget _buildHeader(int memberCount) {
    final l = AppLocalizations.of(context);
    final subtitle = _group.description.isNotEmpty
        ? _group.description
        : l.groupHeaderFriends(memberCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accent.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Text(_group.icon, style: const TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openMenuSheet,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Icon(Icons.menu, size: 19, color: AppColors.textHint),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 5),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansKr(fontSize: 12.5, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  // ── 세그먼트 탭 ──────────────────────────────────────────────────────────────
  Widget _buildTabs(int n, int letterCount, int m) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          _tabItem(l.tabNotice, n, 0),
          _tabItem(l.tabLetters, letterCount, 1),
          _tabItem(l.tabMembers, m, 2),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int count, int index) {
    final on = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _goToTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: on ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: on
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text.rich(
            TextSpan(
              text: label,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: on ? FontWeight.bold : FontWeight.w500,
                color: on ? AppColors.accent : AppColors.textHint,
              ),
              children: [
                if (count > 0)
                  TextSpan(
                    text: ' $count',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: (on ? AppColors.accent : AppColors.textHint).withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 추가하기 FAB ─────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _openAddSheet,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add, size: 22),
      label: Text(AppLocalizations.of(context).groupAdd, style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  void _openAddSheet() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        children: [
          _SheetRow(
            icon: Icons.edit_outlined,
            label: l.groupWriteLetter,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CommunityLetterWriteScreen(
                  groupId: _group.id,
                  groupName: _group.name,
                ),
              )).then((_) => _refresh());
            },
          ),
          if (_isOwner) ...[
            const _SheetDivider(),
            _SheetRow(
              icon: Icons.campaign_outlined,
              label: l.groupPostNotice,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => NoticeWriteScreen(group: _group),
                )).then((_) => _refresh());
              },
            ),
          ],
          const _SheetDivider(),
          _SheetRow(
            icon: Icons.person_add_outlined,
            label: l.groupInviteMember,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => InviteGroupScreen(group: _group),
              ));
            },
          ),
        ],
      ),
    );
  }

  // ── 메뉴(관리) 시트 ──────────────────────────────────────────────────────────
  void _openMenuSheet() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetCard(
        children: [
          if (_isOwner) ...[
            _SheetRow(
              icon: Icons.title,
              label: l.groupRename,
              onTap: () {
                Navigator.pop(context);
                _editTextDialog(
                  title: l.groupRename,
                  initial: _group.name,
                  hint: l.groupRenameHint,
                  onSave: (v) async {
                    if (v.isEmpty) return;
                    await updateGroupName(ref, _group.id, v);
                    setState(() => _group = _copyGroup(name: v));
                    ref.invalidate(myGroupsProvider);
                  },
                );
              },
            ),
            _SheetRow(
              icon: Icons.notes_outlined,
              label: l.groupEditDesc,
              onTap: () {
                Navigator.pop(context);
                _editTextDialog(
                  title: l.groupEditDesc,
                  initial: _group.description,
                  hint: l.groupDescHint,
                  onSave: (v) async {
                    await updateGroupDescription(ref, _group.id, v);
                    setState(() => _group = _copyGroup(description: v));
                    ref.invalidate(myGroupsProvider);
                  },
                );
              },
            ),
            _SheetRow(
              icon: Icons.emoji_emotions_outlined,
              label: l.groupChangeIcon,
              onTap: () {
                Navigator.pop(context);
                _openIconPicker();
              },
            ),
            _SheetRow(
              icon: Icons.manage_accounts_outlined,
              label: l.groupManageMembers,
              onTap: () {
                Navigator.pop(context);
                _goToTab(2);
              },
            ),
            const _SheetDivider(),
          ],
          _SheetRow(
            icon: Icons.logout,
            label: l.groupLeave,
            danger: true,
            onTap: () {
              Navigator.pop(context);
              _confirmLeave();
            },
          ),
        ],
      ),
    );
  }

  CommunityGroup _copyGroup({String? name, String? description, String? icon}) {
    return CommunityGroup(
      id: _group.id,
      name: name ?? _group.name,
      description: description ?? _group.description,
      icon: icon ?? _group.icon,
      inviteCode: _group.inviteCode,
      ownerId: _group.ownerId,
      maxMembers: _group.maxMembers,
      createdAt: _group.createdAt,
    );
  }

  Future<void> _openIconPicker() async {
    final selected = await showGroupIconPicker(context, current: _group.icon);
    if (selected == null || selected == _group.icon) return;
    await updateGroupIcon(ref, _group.id, selected);
    if (!mounted) return;
    setState(() => _group = _copyGroup(icon: selected));
    ref.invalidate(myGroupsProvider);
  }

  void _editTextDialog({
    required String title,
    required String initial,
    required String hint,
    required Future<void> Function(String) onSave,
  }) {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(title, style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.notoSansKr(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSansKr(color: AppColors.textHint),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.buttonCancel, style: GoogleFonts.notoSansKr(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () async {
              final v = controller.text.trim();
              Navigator.pop(context);
              await onSave(v);
            },
            child: Text(l.buttonSave, style: GoogleFonts.notoSansKr(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmLeave() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(l.groupLeave, style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
        content: Text(
          _isOwner
              ? l.groupLeaveOwnerConfirm
              : l.groupLeaveConfirm,
          style: GoogleFonts.notoSansKr(color: AppColors.textPrimary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.buttonCancel, style: GoogleFonts.notoSansKr(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.groupLeaveAction, style: GoogleFonts.notoSansKr(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_isOwner) {
      await deleteGroup(ref, _group.id);
    } else {
      await leaveGroup(ref, _group.id);
    }
    ref.invalidate(myGroupsProvider);
    if (mounted) Navigator.of(context).pop();
  }
}

// ── 공지 리스트 ────────────────────────────────────────────────────────────────
class _NoticeList extends ConsumerWidget {
  final CommunityGroup group;
  final bool isOwner;
  const _NoticeList({required this.group, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final notices = ref.watch(groupNoticesProvider(group.id));
    return notices.when(
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.campaign_outlined,
            title: l.noticeEmptyTitle,
            subtitle: isOwner ? l.noticeEmptyOwner : l.noticeEmptyMember,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          itemCount: list.length,
          itemBuilder: (_, i) => _NoticeCard(
            notice: list[i],
            canDelete: isOwner,
            onDelete: () async {
              await deleteNotice(ref, list[i].id);
              ref.invalidate(groupNoticesProvider(group.id));
            },
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => _EmptyState(
        icon: Icons.error_outline,
        title: l.noticeLoadErrorTitle,
        subtitle: l.noticeLoadErrorSubtitle,
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final GroupNotice notice;
  final bool canDelete;
  final VoidCallback onDelete;
  const _NoticeCard({required this.notice, required this.canDelete, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBF3E0), Color(0xFFF5EAD0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9B96A).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l.noticeBadge, style: GoogleFonts.notoSansKr(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text(
                '${notice.authorName ?? l.roleOwner} · ${_relativeDate(context, notice.createdAt)}',
                style: GoogleFonts.notoSansKr(fontSize: 11, color: AppColors.textHint),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 15, color: AppColors.textHint),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            notice.content,
            style: GoogleFonts.notoSansKr(fontSize: 13.5, color: AppColors.textPrimary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── 서신 리스트 ────────────────────────────────────────────────────────────────
class _LetterList extends ConsumerWidget {
  final CommunityGroup group;
  const _LetterList({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final letters = ref.watch(groupLettersProvider(group.id));
    return letters.when(
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.mail_outline,
            title: l.letterEmptyTitle,
            subtitle: l.letterEmptySubtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          itemCount: list.length,
          itemBuilder: (_, i) => _LetterCard(letter: list[i]),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => Center(child: Text(l.commonError(e.toString()), style: GoogleFonts.notoSansKr(color: AppColors.textHint))),
    );
  }
}

class _LetterCard extends ConsumerWidget {
  final CommunityLetter letter;
  const _LetterCard({required this.letter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prayer = ref.watch(letterPrayerProvider(letter.id));
    final info = prayer.valueOrNull ?? LetterPrayerInfo.empty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(letter.anonymousEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(letter.anonymousName, style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textHint)),
              const Spacer(),
              if (letter.recipientName != null && letter.recipientName!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(l.letterToRecipient(letter.recipientName!), style: GoogleFonts.notoSansKr(fontSize: 10, color: AppColors.accent)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            letter.content,
            style: GoogleFonts.notoSansKr(fontSize: 13, color: AppColors.textPrimary, height: 1.75),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_formatDate(context, letter.createdAt), style: GoogleFonts.notoSansKr(fontSize: 10.5, color: AppColors.textHint)),
          ),
          const Divider(height: 18, color: Color(0x33C4B49A)),
          _PrayerRow(letterId: letter.id, info: info),
        ],
      ),
    );
  }
}

/// 🙏 함께 기도 버튼 + 함께한 사람 아바타 스택
class _PrayerRow extends ConsumerStatefulWidget {
  final String letterId;
  final LetterPrayerInfo info;
  const _PrayerRow({required this.letterId, required this.info});

  @override
  ConsumerState<_PrayerRow> createState() => _PrayerRowState();
}

class _PrayerRowState extends ConsumerState<_PrayerRow> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await toggleLetterPrayer(ref, widget.letterId);
      ref.invalidate(letterPrayerProvider(widget.letterId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showParticipants() {
    final l = AppLocalizations.of(context);
    final info = widget.info;
    if (info.count == 0) return;
    final hiddenCount = info.count - info.participantNames.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2, bottom: 12),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              Text(
                l.prayTogetherCount(info.count),
                style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                l.prayTogetherDesc,
                style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...info.participantNames.map((name) => _ParticipantRow(name: name)),
                      if (hiddenCount > 0)
                        for (var i = 0; i < hiddenCount; i++) _ParticipantRow(name: l.anonymous),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final info = widget.info;
    final prayed = info.prayedByMe;
    return Row(
      children: [
        GestureDetector(
          onTap: _toggle,
          onLongPress: info.count > 0 ? _showParticipants : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: prayed ? AppColors.accent.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: prayed ? AppColors.accent.withValues(alpha: 0.5) : AppColors.divider.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🙏', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  prayed ? l.prayedTogether : l.prayTogether,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: prayed ? AppColors.accent : AppColors.textHint,
                  ),
                ),
                if (info.count > 0) ...[
                  const SizedBox(width: 5),
                  Text('${info.count}', style: GoogleFonts.notoSansKr(fontSize: 11.5, color: prayed ? AppColors.accent : AppColors.textHint)),
                ],
              ],
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: info.count > 0 ? _showParticipants : null,
          behavior: HitTestBehavior.opaque,
          child: _AvatarStack(names: info.participantNames, extra: info.count - info.participantNames.length),
        ),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<String> names;
  final int extra; // 이름 없이 수만 아는 참여자
  const _AvatarStack({required this.names, required this.extra});

  @override
  Widget build(BuildContext context) {
    final shown = names.take(4).toList();
    final remaining = (names.length - shown.length) + (extra > 0 ? extra : 0);
    if (shown.isEmpty && remaining <= 0) return const SizedBox.shrink();

    final avatars = <Widget>[];
    for (var i = 0; i < shown.length; i++) {
      avatars.add(_chip(shown[i].characters.first));
    }
    if (remaining > 0) {
      avatars.add(Padding(
        padding: EdgeInsets.only(left: avatars.isEmpty ? 0 : 4),
        child: Text('+$remaining', style: GoogleFonts.notoSansKr(fontSize: 11, color: AppColors.textHint)),
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: avatars);
  }

  Widget _chip(String ch) {
    return Align(
      widthFactor: 0.72,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB07A6A), Color(0xFF4D4D4D)],
          ),
          border: Border.all(color: AppColors.background, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(ch, style: GoogleFonts.notoSansKr(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// 중보 참여자 목록의 한 줄 — 원형 프로필 아바타 + 이름
class _ParticipantRow extends StatelessWidget {
  final String name;
  const _ParticipantRow({required this.name});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAnon = name.isEmpty || name == l.anonymous;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isAnon
                  ? const LinearGradient(colors: [Color(0xFFD9C9A8), Color(0xFFC4B49A)])
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB07A6A), Color(0xFF4D4D4D)],
                    ),
            ),
            alignment: Alignment.center,
            child: isAnon
                ? const Icon(Icons.person, color: Colors.white, size: 22)
                : Text(
                    name.characters.first,
                    style: GoogleFonts.notoSansKr(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isAnon ? l.anonymousFriend : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 멤버 리스트 ────────────────────────────────────────────────────────────────
class _MemberList extends ConsumerWidget {
  final CommunityGroup group;
  final bool isOwner;
  const _MemberList({required this.group, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final members = ref.watch(groupMembersProvider(group.id));
    final myId = ref.watch(currentUserProvider)?.id;
    return members.when(
      data: (list) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final m = list[i];
          final canKick = isOwner && !m.isOwner && m.userId != myId;
          return _MemberTile(
            member: m,
            canKick: canKick,
            onKick: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.background,
                  title: Text(l.memberKickTitle, style: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold)),
                  content: Text(l.memberKickConfirm(m.userName ?? l.memberDefault), style: GoogleFonts.notoSansKr(height: 1.5)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.buttonCancel, style: GoogleFonts.notoSansKr(color: AppColors.textHint))),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.memberKickAction, style: GoogleFonts.notoSansKr(color: AppColors.accent, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
              if (ok == true) {
                await removeMember(ref, group.id, m.userId);
                ref.invalidate(groupMembersProvider(group.id));
              }
            },
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => Center(child: Text(l.commonError(e.toString()), style: GoogleFonts.notoSansKr(color: AppColors.textHint))),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMember member;
  final bool canKick;
  final VoidCallback onKick;
  const _MemberTile({required this.member, required this.canKick, required this.onKick});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = member.userName ?? l.anonymous;
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: member.isOwner
                  ? const LinearGradient(colors: [Color(0xFFB07A6A), Color(0xFF4D4D4D)])
                  : const LinearGradient(colors: [Color(0xFFD9C9A8), Color(0xFFC4B49A)]),
            ),
            alignment: Alignment.center,
            child: Text(initial, style: GoogleFonts.notoSansKr(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          if (member.isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l.roleOwner, style: GoogleFonts.notoSansKr(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
          if (canKick)
            GestureDetector(
              onTap: onKick,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.remove_circle_outline, size: 19, color: AppColors.textHint),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 공용 위젯 ──────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.divider),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.notoSansKr(fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.textHint, height: 1.5)),
        ],
      ),
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  final List<Widget> children;
  const _BottomSheetCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SheetRow({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.accent : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.notoSansKr(fontSize: 15, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: AppColors.divider.withValues(alpha: 0.4));
  }
}

String _formatDate(BuildContext context, DateTime dt) {
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat.yMMMd(locale).format(dt);
}

String _relativeDate(BuildContext context, DateTime dt) {
  final l = AppLocalizations.of(context);
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l.timeJustNow;
  if (diff.inHours < 1) return l.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24 && now.day == dt.day) return l.timeToday;
  if (diff.inDays < 2) return l.timeYesterday;
  if (diff.inDays < 7) return l.timeDaysAgo(diff.inDays);
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat.MMMd(locale).format(dt);
}
