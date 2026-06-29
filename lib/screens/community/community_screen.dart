import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/community_provider.dart';
import '../../models/community_models.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'pray_for_someone_screen.dart';
import 'community_letter_write_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final myGroups = ref.watch(myGroupsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기도 서신',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 카테고리 가로 스크롤
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _CategoryCircle(
                  icon: Icons.auto_stories_outlined,
                  label: '모두의 서신',
                  isSelected: selectedCategory == 'community',
                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = 'community',
                ),
                _CategoryCircle(
                  icon: Icons.favorite_border,
                  label: '소중한 이에게',
                  isSelected: selectedCategory == 'for_someone',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrayForSomeoneScreen()),
                    );
                  },
                ),
                _CategoryCircle(
                  icon: Icons.group_add_outlined,
                  label: '그룹 만들기',
                  isSelected: false,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                    );
                    ref.invalidate(myGroupsProvider);
                  },
                ),
                // 사용자의 그룹들
                ...myGroups.when(
                  data: (groups) => groups.map((g) => _GroupCircle(
                    group: g,
                    isSelected: false,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => GroupDetailScreen(group: g)),
                      );
                      ref.invalidate(myGroupsProvider);
                    },
                  )),
                  loading: () => [const SizedBox()],
                  error: (_, _) => [const SizedBox()],
                ),
              ],
            ),
          ),
          // 선택된 카테고리에 따른 콘텐츠
          Expanded(
            child: _buildContent(context, ref, selectedCategory, myGroups),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, String category, AsyncValue<List<CommunityGroup>> myGroups) {
    // 그룹은 원형 탭 시 별도 상세 화면(GroupDetailScreen)으로 이동한다.
    return const _CommunityFeed();
  }
}

class _CategoryCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCircle({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : AppColors.card,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.gowunBatang(
                  fontSize: 11,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCircle extends StatelessWidget {
  final CommunityGroup group;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupCircle({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = group.name.isNotEmpty ? group.name.characters.first : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.18)
                    : AppColors.accent.withValues(alpha: 0.08),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.gowunBatang(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                group.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.gowunBatang(
                  fontSize: 11,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeed extends ConsumerWidget {
  const _CommunityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ref.watch(communityLettersProvider);

    return letters.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, size: 44, color: AppColors.divider),
                const SizedBox(height: 14),
                Text(
                  '아직 나눠진 서신이 없어요',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '첫 번째 기도 편지를 남겨보세요',
                  style: GoogleFonts.gowunBatang(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CommunityLetterWriteScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text('편지 쓰기', style: GoogleFonts.gowunBatang(fontSize: 13)),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: list.length,
          itemBuilder: (_, i) => _LetterCard(letter: list[i]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Text('오류: $e', style: GoogleFonts.gowunBatang(color: AppColors.textHint)),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final CommunityLetter letter;
  const _LetterCard({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 편지 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Text(
                  letter.anonymousEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  letter.anonymousName,
                  style: GoogleFonts.gowunBatang(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const Spacer(),
                if (letter.recipientName != null && letter.recipientName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${letter.recipientName}에게',
                      style: GoogleFonts.gowunBatang(
                        fontSize: 10,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 편지 본문
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  letter.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gowunBatang(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatDate(letter.createdAt),
                    style: GoogleFonts.gowunBatang(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}년 ${dt.month}월 ${dt.day}일';
  }
}
