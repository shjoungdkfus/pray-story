import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/prayer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/font_size_picker_sheet.dart';
import '../../widgets/notification_picker_sheet.dart';

Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '기록 삭제',
        style: GoogleFonts.gowunBatang(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        '이 기도 기록을 삭제하시겠습니까?',
        style: GoogleFonts.gowunBatang(color: AppColors.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            '취소',
            style: GoogleFonts.gowunBatang(color: AppColors.textHint),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            '삭제',
            style: GoogleFonts.gowunBatang(
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
  List<DateTime> _alarmTimes = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prayer?.title ?? '');
    _contentController = TextEditingController(text: widget.prayer?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _isSaving = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      String? savedPrayerId;
      if (widget.prayer != null) {
        await supabase.from('prayers').update({
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', widget.prayer!.id);
        savedPrayerId = widget.prayer!.id;
      } else {
        final target = widget.targetDate ?? DateTime.now();
        final now = DateTime.now();
        final isToday = target.year == now.year &&
            target.month == now.month &&
            target.day == now.day;
        final saveDate = isToday
            ? now
            : DateTime(target.year, target.month, target.day, 12, 0, 0);
        final result = await supabase.from('prayers').insert({
          'user_id': user.id,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'created_at': saveDate.toUtc().toIso8601String(),
        }).select('id').single();
        savedPrayerId = result['id'] as String;
      }

      if (_alarmTimes.isNotEmpty) {
        await ref.read(tomorrowAlarmsProvider.notifier).addTomorrowAlarm(
              prayerId: savedPrayerId,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              alarmTimes: _alarmTimes,
            );
      }

      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.prayer != null
                ? '수정되었습니다.'
                : (_isToday ? '오늘의 한 페이지가 기록되었습니다.' : '기도 기록이 저장되었습니다.'),
            style: GoogleFonts.gowunBatang(),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    } on PostgrestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDeleteConfirmDialog(context);
    if (confirmed != true) return;
    if (!mounted) return;

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('prayers').delete().eq('id', widget.prayer!.id);
      ref.invalidate(prayersForDateProvider);
      ref.invalidate(monthPrayersProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기록이 삭제되었습니다.', style: GoogleFonts.gowunBatang()),
          backgroundColor: AppColors.accent,
        ),
      );
    } on PostgrestException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 중 문제가 발생했습니다.')),
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
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.prayer != null ? '기록 수정' : (_isToday ? '오늘의 기록' : '기도 기록'),
          style: GoogleFonts.gowunBatang(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size, color: AppColors.textPrimary, size: 20),
            onPressed: _showFontSizePicker,
          ),
          TextButton(
            onPressed: _isSaving || !_canSave ? null : _save,
            child: Text(
              widget.prayer != null ? '수정' : (_isToday ? '기록하기' : '저장하기'),
              style: GoogleFonts.gowunBatang(
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
                  '삭제',
                  style: GoogleFonts.gowunBatang(
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
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.gowunBatang(
                color: AppColors.textPrimary,
                fontSize: fontSize + 3,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: '기도 제목',
                hintStyle: GoogleFonts.gowunBatang(
                  color: AppColors.textHint,
                  fontSize: fontSize + 3,
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(color: AppColors.divider),
            if (widget.prayer == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _AlarmButton(
                    alarmTimes: _alarmTimes,
                    onTap: () async {
                      await NotificationService.requestPermission();
                      if (!context.mounted) return;
                      final picked = await showNotificationPickerSheet(
                        context,
                        initial: _alarmTimes,
                      );
                      if (picked != null) {
                        setState(() => _alarmTimes = picked);
                      }
                    },
                    onClear: () => setState(() => _alarmTimes = []),
                  ),
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
                    onChanged: (_) => setState(() {}),
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.textPrimary,
                      fontSize: fontSize,
                      height: 2.2,
                      letterSpacing: 0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: '하나님께 올릴 이야기를 작성해주세요.',
                      hintStyle: GoogleFonts.gowunBatang(
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

class _AlarmButton extends StatelessWidget {
  final List<DateTime> alarmTimes;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _AlarmButton({
    required this.alarmTimes,
    required this.onTap,
    required this.onClear,
  });

  String _label() {
    if (alarmTimes.isEmpty) return '알림 설정';
    if (alarmTimes.length == 1) return _formatAlarmTime(alarmTimes.first);
    return '${alarmTimes.length}개 날짜 알림';
  }

  @override
  Widget build(BuildContext context) {
    final isSet = alarmTimes.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSet ? AppColors.accent : AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              size: 16,
              color: isSet ? Colors.white : AppColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              _label(),
              style: GoogleFonts.gowunBatang(
                color: isSet ? Colors.white : AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSet) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAlarmTime(DateTime time) {
    final now = DateTime.now();
    final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? '오전' : '오후';
    final minute = time.minute.toString().padLeft(2, '0');
    final timeStr = '$period $hour12:$minute';
    return isToday ? timeStr : '${time.month}/${time.day} $timeStr';
  }
}
