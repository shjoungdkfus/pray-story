import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_model.dart';
import '../../providers/nav_provider.dart';
import '../../providers/prayer_provider.dart';

class HistorySearchOverlay extends ConsumerStatefulWidget {
  const HistorySearchOverlay({super.key});

  @override
  ConsumerState<HistorySearchOverlay> createState() =>
      _HistorySearchOverlayState();
}

class _HistorySearchOverlayState extends ConsumerState<HistorySearchOverlay>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _animController;
  List<PrayerModel> _lastResults = const [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    if (value.trim().isNotEmpty) {
      _animController.forward();
    } else {
      _animController.reverse().then((_) {
        if (mounted) setState(() => _lastResults = const []);
      });
    }
  }

  void _selectPrayer(PrayerModel prayer) {
    ref.read(selectedDateProvider.notifier).state = prayer.createdAt;
    // 검색은 달력(기도기록, 탭 1)에 있으므로, 선택 시 메인(탭 0)으로 이동하고
    // 돌아갈 탭을 기록해 둔다.
    ref.read(previousTabProvider.notifier).state = 1;
    ref.read(shellTabProvider.notifier).state = 0;
    _controller.clear();
    _onChanged('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<PrayerModel>>>(searchResultsProvider, (_, next) {
      next.whenData((list) {
        if (list.isNotEmpty && mounted) {
          setState(() => _lastResults = list);
        }
      });
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildResultsList(),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.searchBar,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: GoogleFonts.gowunBatang(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: '날짜, 기도 제목, 키워드로 기록을 찾아보세요',
          hintStyle: GoogleFonts.gowunBatang(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return SizeTransition(
      sizeFactor: _animController,
      axisAlignment: -1,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        color: AppColors.searchBar,
        child: Consumer(
          builder: (context, ref, _) {
            final results = ref.watch(searchResultsProvider);
            final display = results.maybeWhen(
              data: (list) => list.isNotEmpty ? list : _lastResults,
              orElse: () => _lastResults,
            );
            if (display.isEmpty) return const SizedBox.shrink();
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: display.length,
              separatorBuilder: (_, __) => Divider(
                color: AppColors.divider,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) => _ResultTile(
                prayer: display[i],
                onTap: () => _selectPrayer(display[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final PrayerModel prayer;
  final VoidCallback onTap;

  const _ResultTile({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy년 M월 d일', 'ko').format(prayer.createdAt);
    return ListTile(
      onTap: onTap,
      leading: Text(
        dateStr,
        style: GoogleFonts.gowunBatang(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(
        prayer.title.isEmpty ? '(제목 없음)' : prayer.title,
        style: GoogleFonts.gowunBatang(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        prayer.content,
        style: GoogleFonts.gowunBatang(
          color: AppColors.textHint,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
