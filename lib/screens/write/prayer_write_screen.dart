import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/prayer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/local_prayer_store.dart';
import '../../widgets/font_size_picker_sheet.dart';

/// 기도문 삭제 후 "되돌리기(Undo)" 스낵바를 띄운다. (B1, FR-004)
///
/// [messenger]/[container]/[l]은 **호출 측이 pop/rebuild 이전에 캡처해서** 넘긴다.
/// 삭제 후 원래 위젯(ref·context)이 폐기돼도 Undo가 동작해야 하기 때문.
/// 앱 루트 [ProviderContainer]는 앱 수명 내내 살아있어 재insert·invalidate가 안전하다.
void showPrayerDeletedSnackBar({
  required ScaffoldMessengerState messenger,
  required ProviderContainer container,
  required AppLocalizations l,
  required PrayerModel deleted,
}) {
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: AppColors.accent,
      duration: const Duration(seconds: 5),
      // 전역 snackBarTheme의 글자색(다크=검정)을 그대로 두면 accent 배경과 2.48:1로
      // 대비가 부족하다 — 배경을 덮는 스낵바는 글자색도 함께 지정한다(PS-UI-02).
      content: Text(l.recordDeleted,
          style: GoogleFonts.notoSansKr(color: Colors.white)),
      action: SnackBarAction(
        label: l.undoDelete,
        textColor: Colors.white,
        onPressed: () async {
          try {
            await restorePrayer(container.read(supabaseProvider), deleted);
            container.invalidate(prayersForDateProvider);
            container.invalidate(monthPrayersProvider);
          } catch (_) {
            messenger.showSnackBar(
              SnackBar(content: Text(l.errRestoreFailed)),
            );
          }
        },
      ),
    ),
  );
}

Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.writeDeleteTitle,
        style: GoogleFonts.notoSansKr(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        l.writeDeleteMessage,
        style: GoogleFonts.notoSansKr(color: AppColors.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            l.buttonCancel,
            style: GoogleFonts.notoSansKr(color: AppColors.textHint),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            l.buttonDelete,
            style: GoogleFonts.notoSansKr(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

class PrayerWriteScreen extends ConsumerStatefulWidget {
  final DateTime? targetDate;
  final PrayerModel? prayer;
  const PrayerWriteScreen({super.key, this.targetDate, this.prayer});

  @override
  ConsumerState<PrayerWriteScreen> createState() => _PrayerWriteScreenState();
}

class _PrayerWriteScreenState extends ConsumerState<PrayerWriteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;
  Timer? _draftDebounce;

  // 신규 작성 모드만 draft 자동저장 대상 (수정 모드는 원본이 서버에 있으니 제외).
  bool get _isNewMode => widget.prayer == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prayer?.title ?? '');
    _contentController = TextEditingController(text: widget.prayer?.content ?? '');
    if (_isNewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
    }
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    if (_isNewMode) _scheduleDraftSave();
  }

  // 입력 변경 후 800ms 디바운스 뒤 draft 1건 저장 (내용 비면 삭제). (B2, FR-005)
  void _scheduleDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 800), () {
      final title = _titleController.text;
      final content = _contentController.text;
      if (title.trim().isEmpty && content.trim().isEmpty) {
        LocalPrayerStore.clearDraft();
      } else {
        LocalPrayerStore.saveDraft(
          title: title,
          content: content,
          targetDate: widget.targetDate ?? DateTime.now(),
        );
      }
    });
  }

  Future<void> _restoreDraft() async {
    final draft = await LocalPrayerStore.loadDraft();
    if (draft == null || draft.isEmpty || !mounted) return;
    // 단일 전역 draft라 날짜 불일치 시 되살리면 엉뚱한 날짜로 저장될 수 있어
    // 같은 날짜(targetDate) draft만 복원한다.
    final target = widget.targetDate ?? DateTime.now();
    if (!DateUtils.isSameDay(draft.targetDate, target)) return;
    // 사용자가 이미 입력을 시작했으면 덮어쓰지 않는다.
    if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
      return;
    }
    _titleController.text = draft.title;
    _contentController.text = draft.content;
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).draftRestored,
          style: GoogleFonts.notoSansKr(),
        ),
      ),
    );
  }

  Future<void> _save() async {
    // 버튼의 onPressed 비활성화는 다음 build를 기다려야 반영되므로,
    // 그 사이 연타가 들어와도 막히도록 함수 진입 시점에도 재확인한다.
    if (_isSaving || !_canSave) return;
    final l = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      if (widget.prayer != null) {
        // .select() 없이 update만 하면 대상이 0행이어도(예: 다른 기기에서 이미
        // 삭제됨) 에러 없이 끝나 "수정 성공"처럼 보인다 — 실제 반영행을 확인한다.
        final updated = await supabase
            .from('prayers')
            .update({
              'title': _titleController.text.trim(),
              'content': _contentController.text.trim(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', widget.prayer!.id)
            .select();
        if ((updated as List).isEmpty) {
          ref.invalidate(prayersForDateProvider);
          ref.invalidate(monthPrayersProvider);
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);
          Navigator.pop(context);
          messenger.showSnackBar(SnackBar(content: Text(l.errPrayerNotFound)));
          return;
        }
      } else {
        final target = widget.targetDate ?? DateTime.now();
        final now = DateTime.now();
        final isToday = target.year == now.year &&
            target.month == now.month &&
            target.day == now.day;
        final saveDate = isToday
            ? now
            : DateTime(target.year, target.month, target.day, 12, 0, 0);
        await supabase.from('prayers').insert({
          'user_id': user.id,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'created_at': saveDate.toUtc().toIso8601String(),
        });
      }

      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);

      // 저장 성공 → draft 폐기 (신규 모드만). 대기 중 디바운스도 취소.
      if (_isNewMode) {
        _draftDebounce?.cancel();
        await LocalPrayerStore.clearDraft();
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.prayer != null
                ? l.writeUpdated
                : (_isToday ? l.writeSavedToday : l.writeSaved),
            // accent 배경 위 글자색을 명시(PS-UI-02).
            style: GoogleFonts.notoSansKr(color: Colors.white),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (_) {
      // Postgrest(서버) 오류뿐 아니라 네트워크 예외도 조용히 삼키지 않고 알린다.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDeleteConfirmDialog(context);
    if (confirmed != true) return;
    if (!mounted) return;

    // pop 이후엔 이 위젯의 ref/context가 폐기되므로 Undo에 필요한 것을 미리 캡처.
    final deleted = widget.prayer!;
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('prayers').delete().eq('id', deleted.id);
      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);
      if (!mounted) return;
      Navigator.pop(context);
      showPrayerDeletedSnackBar(
        messenger: messenger,
        container: container,
        l: l,
        deleted: deleted,
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.errDeleteFailed)),
      );
    }
  }

  void _showFontSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const FontSizePickerSheet(),
    );
  }

  bool get _isToday {
    final target = widget.targetDate ?? DateTime.now();
    final now = DateTime.now();
    return target.year == now.year &&
        target.month == now.month &&
        target.day == now.day;
  }

  bool get _canSave {
    if (_contentController.text.trim().isEmpty) return false;
    if (widget.prayer != null) {
      return _titleController.text.trim() != widget.prayer!.title ||
          _contentController.text.trim() != widget.prayer!.content;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          // 저장 진행 중엔 시트 닫기 차단 (비동기 경합 방지).
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          widget.prayer != null
              ? l.writeTitleEdit
              : (_isToday ? l.writeTitleToday : l.writeTitleOther),
          style: GoogleFonts.notoSansKr(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.format_size, color: AppColors.textPrimary, size: 20),
            onPressed: _showFontSizePicker,
          ),
          TextButton(
            onPressed: _isSaving || !_canSave ? null : _save,
            // 종전엔 저장 중에도 인디케이터가 없고 버튼 색이 _isSaving을 반영하지
            // 않아 '활성처럼' 보였다(PS-UI-15).
            child: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentText,
                    ),
                  )
                : Text(
              widget.prayer != null
                  ? l.writeSubmitEdit
                  : (_isToday ? l.writeSubmitToday : l.writeSubmitOther),
              style: GoogleFonts.notoSansKr(
                color: _canSave && !_isSaving
                    ? AppColors.accentText
                    : AppColors.textHint,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (widget.prayer != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _delete,
                child: Text(
                  l.buttonDelete,
                  style: GoogleFonts.notoSansKr(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.prayer == null)
            const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              onChanged: (_) => _onChanged(),
              style: GoogleFonts.notoSansKr(
                color: AppColors.textPrimary,
                fontSize: fontSize + 3,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: l.writeHintTitle,
                hintStyle: GoogleFonts.notoSansKr(
                  color: AppColors.textHint,
                  fontSize: fontSize + 3,
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  _NoteLinesPainter(style: _contentLineStyle(fontSize)),
                  TextField(
                    controller: _contentController,
                    onChanged: (_) => _onChanged(),
                    maxLines: null,
                    expands: true,
                    // 커서 기본 높이는 TextStyle.height(2.2, 노트 줄간격용)를
                    // 그대로 따라가 실제 글자 크기보다 훨씬 커 보였다(PS-UI-21).
                    // 줄간격 배수와 분리해 글자 크기 비례로 고정한다.
                    cursorHeight: fontSize * 1.2,
                    // 명시하지 않아도 EditableText가 내부적으로 같은 값을
                    // 자동 적용하지만(강제 균일 줄높이), 배경 노트줄 페인터가
                    // 그 값에 의존하므로 암묵적 동작에 맡기지 않고 명시한다.
                    strutStyle: StrutStyle.fromTextStyle(
                      _contentLineStyle(fontSize),
                      forceStrutHeight: true,
                    ),
                    style: _contentLineStyle(fontSize)
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: l.writeHintContent,
                      hintStyle: _contentLineStyle(fontSize)
                          .copyWith(color: AppColors.textHint),
                      border: InputBorder.none,
                      filled: false,
                      // 배경 노트줄(_NoteLinesPainter)이 같은 Stack 좌표계(y=0
                      // 시작)를 기준으로 줄 간격을 계산한다. TextField 기본
                      // contentPadding이 남아있으면 첫 줄부터 어긋나므로
                      // 0으로 고정해 텍스트 원점과 페인터 원점을 일치시킨다.
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 본문 [TextField]와 배경 노트줄(_LinesPainter)이 공유하는 스타일.
///
/// 이전엔 이 스타일을 두 곳에서 각각 직접 만들었는데(TextField의 `style:`과
/// `_LinesPainter`의 `fontSize*2.2` 근사식), 서로 다른 계산 경로라 실기기에서
/// 어긋났다(PS-UI-20). 색상만 빼고 하나로 합쳐 divergence 자체를 없앤다.
TextStyle _contentLineStyle(double fontSize) => GoogleFonts.notoSansKr(
      fontSize: fontSize,
      height: 2.2,
      letterSpacing: 0.5,
    );

class _NoteLinesPainter extends StatelessWidget {
  final TextStyle style;
  const _NoteLinesPainter({required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LinesPainter(style: style),
        );
      },
    );
  }
}

class _LinesPainter extends CustomPainter {
  final TextStyle style;
  const _LinesPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;

    // fontSize*2.2 근사식 대신, 실제 텍스트 레이아웃 엔진으로 한 줄 높이를
    // 측정한다. 단 TextField(EditableText)는 strutStyle을 지정하지 않으면
    // 내부적으로 StrutStyle.fromTextStyle(style, forceStrutHeight: true)를
    // 자동 적용해 모든 줄 높이를 강제 통일한다(Flutter SDK
    // editable_text.dart의 `strutStyle` getter) — 이 strut 없이 순수
    // TextPainter만으로 측정하면 실제 TextField 줄 간격보다 커서 아래로
    // 갈수록 어긋났다. 실제 TextField와 동일한 strut을 명시해야 일치한다.
    final strut = StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    final tp = TextPainter(
      text: TextSpan(text: '가', style: style),
      strutStyle: strut,
      textDirection: TextDirection.ltr,
    )..layout();
    final lineHeight = tp.height;
    tp.dispose();

    var y = lineHeight;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => old.style != style;
}
