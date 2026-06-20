import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/community_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import 'invite_group_screen.dart';

class GroupInfoScreen extends ConsumerWidget {
  final CommunityGroup group;
  const GroupInfoScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider(group.id));
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.id == group.ownerId;
    final initial = group.name.isNotEmpty ? group.name.characters.first : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '그룹 정보',
          style: GoogleFonts.gowunBatang(color: AppColors.textPrimary, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onSelected: (value) async {
              if (value == 'leave') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('그룹 나가기', style: GoogleFonts.gowunBatang()),
                    content: Text('정말 이 그룹을 나가시겠습니까?', style: GoogleFonts.gowunBatang()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('취소', style: GoogleFonts.gowunBatang()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('나가기', style: GoogleFonts.gowunBatang(color: AppColors.accent)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await leaveGroup(ref, group.id);
                  ref.invalidate(myGroupsProvider);
                  if (context.mounted) Navigator.of(context).pop();
                }
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('그룹 삭제', style: GoogleFonts.gowunBatang()),
                    content: Text('이 그룹과 모든 편지가 삭제됩니다.\n정말 삭제하시겠습니까?', style: GoogleFonts.gowunBatang()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('취소', style: GoogleFonts.gowunBatang()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('삭제', style: GoogleFonts.gowunBatang(color: AppColors.accent)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await deleteGroup(ref, group.id);
                  ref.invalidate(myGroupsProvider);
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'leave',
                child: Text('그룹 나가기', style: GoogleFonts.gowunBatang()),
              ),
              if (isOwner)
                PopupMenuItem(
                  value: 'delete',
                  child: Text('그룹 삭제', style: GoogleFonts.gowunBatang(color: AppColors.accent)),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // 그룹 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.gowunBatang(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                group.name,
                style: GoogleFonts.gowunBatang(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isOwner) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showRenameDialog(context, ref),
                  child: const Icon(Icons.edit, size: 18, color: AppColors.textHint),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          members.when(
            data: (m) => Text(
              '멤버 ${m.length}명',
              style: GoogleFonts.gowunBatang(fontSize: 13, color: AppColors.textHint),
            ),
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
          ),
          const SizedBox(height: 24),
          // 멤버 리스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                members.when(
                  data: (m) => Text(
                    '${m.length} / ${group.maxMembers} 멤버',
                    style: GoogleFonts.gowunBatang(fontSize: 13, color: AppColors.textHint),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => InviteGroupScreen(group: group),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text('초대하기', style: GoogleFonts.gowunBatang(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: members.when(
              data: (list) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => _MemberTile(member: list[i]),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
          // 생성일
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${group.createdAt.year}년 ${group.createdAt.month}월 ${group.createdAt.day}일에 만들어짐',
              style: GoogleFonts.gowunBatang(fontSize: 12, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('그룹 이름 변경', style: GoogleFonts.gowunBatang()),
        content: TextField(
          controller: controller,
          style: GoogleFonts.gowunBatang(),
          decoration: InputDecoration(
            hintText: '새 그룹 이름',
            hintStyle: GoogleFonts.gowunBatang(color: AppColors.textHint),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.gowunBatang()),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await updateGroupName(ref, group.id, newName);
                ref.invalidate(myGroupsProvider);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('변경', style: GoogleFonts.gowunBatang(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMember member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            member.userName ?? member.userId.substring(0, 8),
            style: GoogleFonts.gowunBatang(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (member.isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '방장',
                style: GoogleFonts.gowunBatang(
                  fontSize: 11,
                  color: AppColors.accent,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }
}
