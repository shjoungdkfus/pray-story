import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
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
      // 성공한 결과는 빈 리스트도 그대로 반영해야 "검색결과 없음"과
      // 이전 결과가 남아있는 상태가 헷갈리지 않는다. 에러일 땐 건드리지 않고
      // _buildResultsList의 loading 분기가 이 값을 잠깐 유지해 깜빡임만 막는다.
      next.whenData((list) {
        if (mounted) setState(() => _lastResults = list);
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
        style: GoogleFonts.notoSansKr(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchHint,
          hintStyle: GoogleFonts.notoSansKr(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.textHint),
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
            return results.when(
              // 검색어 타이핑 중 재요청이 뜨는 잠깐 사이엔 이전 결과를 유지해
              // 깜빡임을 막는다(진짜 결과 반영은 data에서만).
              loading: () => _buildList(_lastResults),
              data: _buildList,
              // 오프라인 등으로 요청 자체가 실패한 경우 — 이전 검색어의 결과를
              // 그대로 보여주면 "지금 검색어로도 찾아졌다"고 오인하게 되므로
              // 조용히 넘어가지 않고 실패를 알린다.
              error: (_, _) => _buildSearchError(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<PrayerModel> items) {
    // 종전엔 0건이면 패널이 아예 안 떠서 "검색이 동작했는지"조차 알 수 없었다(PS-UI-09).
    // 검색어가 있는데 결과가 없으면 그 사실을 명시한다.
    if (items.isEmpty) {
      if (_controller.text.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Text(
          AppLocalizations.of(context).searchEmptyResult,
          style: GoogleFonts.notoSansKr(
            color: AppColors.textHint,
            fontSize: 13,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.divider,
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (_, i) => _ResultTile(
        prayer: items[i],
        onTap: () => _selectPrayer(items[i]),
      ),
    );
  }

  Widget _buildSearchError(BuildContext context) {
    if (_controller.text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        AppLocalizations.of(context).searchError,
        style: GoogleFonts.notoSansKr(color: AppColors.textHint, fontSize: 13),
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
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat.yMMMd(locale).format(prayer.createdAt);
    return ListTile(
      onTap: onTap,
      leading: Text(
        dateStr,
        style: GoogleFonts.notoSansKr(
          color: AppColors.accentText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(
        prayer.title.isEmpty ? l.searchUntitled : prayer.title,
        style: GoogleFonts.notoSansKr(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        prayer.content,
        style: GoogleFonts.notoSansKr(
          color: AppColors.textHint,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
