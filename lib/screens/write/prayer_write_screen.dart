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
      content: Text(l.recordDeleted, style: GoogleFonts.notoSansKr()),
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
              color: Colors.red,
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
    if (!_canSave) return;
    final l = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      if (widget.prayer != null) {
        await supabase.from('prayers').update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', widget.prayer!.id);
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
            style: GoogleFonts.notoSansKr(),
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
            child: Text(
              widget.prayer != null
                  ? l.writeSubmitEdit
                  : (_isToday ? l.writeSubmitToday : l.writeSubmitOther),
              style: GoogleFonts.notoSansKr(
                color: _canSave ? AppColors.accent : AppColors.textHint,
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
                    color: Colors.red.withValues(alpha: 0.8),
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
                  _NoteLinesPainter(fontSize: fontSize),
                  TextField(
                    controller: _contentController,
                    onChanged: (_) => _onChanged(),
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.notoSansKr(
                      color: AppColors.textPrimary,
                      fontSize: fontSize,
                      height: 2.2,
                      letterSpacing: 0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: l.writeHintContent,
                      hintStyle: GoogleFonts.notoSansKr(
                        color: AppColors.textHint,
                        fontSize: fontSize,
                        height: 2.2,
                      ),
                      border: InputBorder.none,
                      filled: false,
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

class _NoteLinesPainter extends StatelessWidget {
  final double fontSize;
  const _NoteLinesPainter({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LinesPainter(fontSize: fontSize),
        );
      },
    );
  }
}

class _LinesPainter extends CustomPainter {
  final double fontSize;
  const _LinesPainter({required this.fontSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;

    final lineHeight = fontSize * 2.2;
    var y = lineHeight;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => old.fontSize != fontSize;
}
