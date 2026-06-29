import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/community_models.dart';
import '../../providers/community_provider.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    ref.invalidate(myGroupsProvider);
  }

  Future<void> _openJoin(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
    );
    ref.invalidate(myGroupsProvider);
  }

  Future<void> _openGroup(BuildContext context, WidgetRef ref, CommunityGroup g) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GroupDetailScreen(group: g)),
    );
    ref.invalidate(myGroupsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGroups = ref.watch(myGroupsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              '기도 모임',
              style: GoogleFonts.gowunBatang(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              '가족·친구와 함께 기도를 나눠요',
              style: GoogleFonts.gowunBatang(fontSize: 13, color: AppColors.textHint),
            ),
          ),
          // 액션 버튼 (모임 만들기 / 초대 코드)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add,
                    label: '모임 만들기',
                    filled: true,
                    onTap: () => _openCreate(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.vpn_key_outlined,
                    label: '초대 코드',
                    filled: false,
                    onTap: () => _openJoin(context, ref),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              '내 모임',
              style: GoogleFonts.gowunBatang(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textHint),
            ),
          ),
          // 내 모임 목록
          Expanded(
            child: myGroups.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return _EmptyGroups(onCreate: () => _openCreate(context, ref));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _GroupCard(
                    group: groups[i],
                    onTap: () => _openGroup(context, ref, groups[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                child: Text('오류: $e', style: GoogleFonts.gowunBatang(color: AppColors.textHint)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: filled ? Colors.white : AppColors.textPrimary),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.gowunBatang(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: filled ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = group.description.isNotEmpty ? group.description : '함께 기도하는 모임';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
              alignment: Alignment.center,
              child: Text(group.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.gowunBatang(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.gowunBatang(fontSize: 12.5, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyGroups({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 48, color: AppColors.divider),
          const SizedBox(height: 16),
          Text('아직 모임이 없어요', style: GoogleFonts.gowunBatang(fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            '가족·친구와 함께 기도할\n첫 모임을 만들어보세요',
            textAlign: TextAlign.center,
            style: GoogleFonts.gowunBatang(fontSize: 12.5, color: AppColors.textHint, height: 1.6),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onCreate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('모임 만들기', style: GoogleFonts.gowunBatang(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
