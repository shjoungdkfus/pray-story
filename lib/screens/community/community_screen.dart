import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              l.communityTitle,
              style: GoogleFonts.notoSansKr(
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
              l.communitySubtitle,
              style: GoogleFonts.notoSansKr(fontSize: 13, color: AppColors.textHint),
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
                    label: l.communityCreateGroup,
                    filled: true,
                    onTap: () => _openCreate(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.vpn_key_outlined,
                    label: l.communityInviteCode,
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
              l.communityMyGroups,
              style: GoogleFonts.notoSansKr(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textHint),
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
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                child: Text(l.commonError(e.toString()), style: GoogleFonts.notoSansKr(color: AppColors.textHint)),
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
              style: GoogleFonts.notoSansKr(
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
    final l = AppLocalizations.of(context);
    final subtitle = group.description.isNotEmpty ? group.description : l.communityGroupDefaultDesc;
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
                    style: GoogleFonts.notoSansKr(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansKr(fontSize: 12.5, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
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
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 48, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(l.communityEmptyTitle, style: GoogleFonts.notoSansKr(fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            l.communityEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(fontSize: 12.5, color: AppColors.textHint, height: 1.6),
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
                  Text(l.communityCreateGroup, style: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
