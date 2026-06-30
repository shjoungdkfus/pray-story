import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

Future<List<DateTime>?> showNotificationPickerSheet(
  BuildContext context, {
  List<DateTime>? initial,
}) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final base = (initial != null && initial.isNotEmpty) ? initial.first : now.add(const Duration(hours: 12));
  final initialDates = (initial != null && initial.isNotEmpty)
      ? initial.map((d) => DateTime(d.year, d.month, d.day)).toSet()
      : {tomorrow};

  return showDialog<List<DateTime>>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: _AlarmTimeSheet(
        initialDates: initialDates,
        initialHour: base.hour,
        initialMinute: base.minute,
      ),
    ),
  );
}

const double _itemExtent = 60;
const _softColor = Color(0xFF8A6D58); // 옅은 세피아 — 잠들기 전 느낌
const _editHighlight = Color(0x668A6D58); // 입력 중인 칸 음영

enum _EditTarget { none, hour, minute }

class _AlarmTimeSheet extends StatefulWidget {
  final Set<DateTime> initialDates;
  final int initialHour;
  final int initialMinute;

  const _AlarmTimeSheet({
    required this.initialDates,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  State<_AlarmTimeSheet> createState() => _AlarmTimeSheetState();
}

class _AlarmTimeSheetState extends State<_AlarmTimeSheet> with SingleTickerProviderStateMixin {
  late final FixedExtentScrollController _periodController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late Set<DateTime> _selectedDates;

  _EditTarget _editTarget = _EditTarget.none;
  String _editBuffer = '';

  OverlayEntry? _numPadEntry;
  AnimationController? _numPadAnimController;

  @override
  void initState() {
    super.initState();
    final isPm = widget.initialHour >= 12;
    final hour12 = widget.initialHour % 12 == 0 ? 12 : widget.initialHour % 12;

    _periodController = FixedExtentScrollController(initialItem: isPm ? 1 : 0);
    _hourController = FixedExtentScrollController(initialItem: hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: widget.initialMinute);
    _selectedDates = {...widget.initialDates};
  }

  @override
  void dispose() {
    // 다이얼로그가 닫히는 경로(취소/확인/바깥 탭/뒤로가기)와 상관없이 화면에
    // 남아있는 숫자 패드 오버레이를 정리한다 — 애니메이션 없이 즉시 제거.
    _numPadAnimController?.dispose();
    _numPadEntry?.remove();
    _periodController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  static int _wrapIndex(int raw, int length) => ((raw % length) + length) % length;

  // 숫자 패드 입력 — 다른 칸으로 옮기면 버퍼를 휠 값으로 반영하고 패드는 그대로 띄워둔다.
  // 기존 값은 박스에 보여주기만 하고, 숫자를 누르는 순간 새로 입력을 시작한다.
  void _startEdit(_EditTarget target) {
    if (_editTarget != _EditTarget.none) _commitBuffer();
    final current = target == _EditTarget.hour
        ? _wrapIndex(_hourController.selectedItem, 12) + 1
        : _wrapIndex(_minuteController.selectedItem, 60);
    setState(() {
      _editTarget = target;
      _editBuffer = '$current';
    });
    _ensureNumPadVisible();
  }

  // 화면 맨 아래에서 올라오는 숫자 패드 — 모달 배리어 없이 Overlay에 직접 끼워 넣어서
  // 뒤에 있는 알림 시간 창(오전/오후 휠 포함)이 그대로 터치되도록 한다.
  void _ensureNumPadVisible() {
    if (_numPadEntry != null) return;
    final animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _numPadAnimController = animController;

    final entry = OverlayEntry(
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animController, curve: Curves.easeOut)),
            child: SafeArea(
              top: false,
              child: Material(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: _NumPad(
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  onDone: _finishEdit,
                ),
              ),
            ),
          ),
        );
      },
    );
    _numPadEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    animController.forward();
  }

  void _hideNumPad() {
    final entry = _numPadEntry;
    final animController = _numPadAnimController;
    if (entry == null || animController == null) return;
    _numPadEntry = null;
    _numPadAnimController = null;
    animController.reverse().whenComplete(() {
      entry.remove();
      animController.dispose();
    });
  }

  // 시는 1~12, 분은 0~59 범위를 넘는 값은 받지 않는다.
  bool _isValidValue(String value) {
    final n = int.parse(value);
    return _editTarget == _EditTarget.hour ? (n >= 1 && n <= 12) : (n >= 0 && n <= 59);
  }

  // 한 자리(예: "1")일 때만 이어붙여서 10/11/12, 00~59처럼 두 자리를 만들 수 있다.
  // 그 외에는 누르는 숫자로 완전히 새로 시작한다 (기존 값은 지워짐).
  void _appendDigit(String digit) {
    final extended = '$_editBuffer$digit';
    final newBuffer = (_editBuffer.length == 1 && _isValidValue(extended)) ? extended : digit;
    if (!_isValidValue(newBuffer)) return;
    setState(() => _editBuffer = newBuffer);
  }

  void _backspace() {
    if (_editBuffer.isEmpty) return;
    setState(() => _editBuffer = _editBuffer.substring(0, _editBuffer.length - 1));
  }

  // 입력 중에는 휠(CupertinoPicker) 자체가 화면에서 빠져 있어서 컨트롤러가
  // 어떤 스크롤뷰에도 붙어있지 않다 — 그 상태에서 jumpToItem을 호출하면 반영되지
  // 않는다. 그래서 같은 시작 위치를 가진 새 컨트롤러로 갈아끼운다.
  void _commitBuffer() {
    if (_editBuffer.isEmpty) return;
    final parsed = int.parse(_editBuffer);
    if (_editTarget == _EditTarget.hour) {
      _hourController.dispose();
      _hourController = FixedExtentScrollController(initialItem: parsed.clamp(1, 12) - 1);
    } else if (_editTarget == _EditTarget.minute) {
      _minuteController.dispose();
      _minuteController = FixedExtentScrollController(initialItem: parsed.clamp(0, 59));
    }
  }

  void _finishEdit() {
    _commitBuffer();
    setState(() {
      _editTarget = _EditTarget.none;
      _editBuffer = '';
    });
    _hideNumPad();
  }

  void _confirm() {
    if (_selectedDates.isEmpty) return;
    final periodIndex = _wrapIndex(_periodController.selectedItem, 2);

    // 패드로 입력 중인 값은 아직 휠에 반영되지 않았을 수 있으니 버퍼를 우선한다.
    final hour12 = (_editTarget == _EditTarget.hour && _editBuffer.isNotEmpty)
        ? int.parse(_editBuffer).clamp(1, 12)
        : _wrapIndex(_hourController.selectedItem, 12) + 1;
    final minute = (_editTarget == _EditTarget.minute && _editBuffer.isNotEmpty)
        ? int.parse(_editBuffer).clamp(0, 59)
        : _wrapIndex(_minuteController.selectedItem, 60);

    var hour = hour12 % 12;
    if (periodIndex == 1) hour += 12;

    final results = _selectedDates
        .map((d) => DateTime(d.year, d.month, d.day, hour, minute))
        .toList()
      ..sort();
    Navigator.pop(context, results);
  }

  // 자정을 막 넘긴 시각에 작업 중이면 시스템상의 "오늘"이 이미 다음 날로 넘어가 있어
  // 자동으로 계산한 "내일"이 사용자 입장과 어긋날 수 있다 — 직접 날짜를 고를 수 있게 한다.
  Future<void> _pickDate() async {
    var picked = {..._selectedDates};
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '취소',
                    style: GoogleFonts.gowunBatang(color: AppColors.textHint, fontSize: 15),
                  ),
                ),
                Text(
                  '날짜 선택',
                  style: GoogleFonts.gowunBatang(
                    color: _softColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedDates = picked);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    '확인',
                    style: GoogleFonts.gowunBatang(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _MultiDateCalendar(
            initialSelected: picked,
            firstDate: todayOnly,
            lastDate: todayOnly.add(const Duration(days: 365)),
            onChanged: (s) => picked = s,
          ),
          const SizedBox(height: 8),
          Text(
            '탭으로 하나씩, 드래그로 여러 날짜를 한번에 선택할 수 있어요.',
            style: GoogleFonts.gowunBatang(color: AppColors.textHint, fontSize: 11),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _dateSummaryLabel() {
    if (_selectedDates.isEmpty) return '날짜를 선택해주세요';
    final sorted = _selectedDates.toList()..sort();
    if (sorted.length == 1) {
      final date = sorted.first;
      final relative = _relativeLabel(date);
      final dateLabel = DateFormat('M월 d일 (E)', 'ko').format(date);
      return relative != null ? '$relative · $dateLabel' : dateLabel;
    }
    final first = DateFormat('M월 d일', 'ko').format(sorted.first);
    return '$first 외 ${sorted.length - 1}일 · 총 ${sorted.length}일 선택';
  }

  String? _relativeLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: GoogleFonts.gowunBatang(color: AppColors.textHint, fontSize: 15),
                ),
              ),
              Text(
                '알림 시간',
                style: GoogleFonts.gowunBatang(
                  color: _softColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _confirm,
                child: Text(
                  '확인',
                  style: GoogleFonts.gowunBatang(
                    color: AppColors.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _itemExtent * 3,
          child: Row(
            children: [
              Expanded(
                child: _PeriodWheel(controller: _periodController),
              ),
              Expanded(
                child: _TimeWheelSlot(
                  controller: _hourController,
                  itemCount: 12,
                  displayOffset: 1,
                  looping: true,
                  editing: _editTarget == _EditTarget.hour,
                  editBuffer: _editBuffer,
                  onTap: () => _startEdit(_EditTarget.hour),
                ),
              ),
              Text(
                ':',
                style: GoogleFonts.gowunBatang(
                  color: _softColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: _TimeWheelSlot(
                  controller: _minuteController,
                  itemCount: 60,
                  displayOffset: 0,
                  looping: true,
                  padTwoDigits: true,
                  editing: _editTarget == _EditTarget.minute,
                  editBuffer: _editBuffer,
                  onTap: () => _startEdit(_EditTarget.minute),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _dateSummaryLabel(),
                      style: GoogleFonts.gowunBatang(color: _softColor, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined, color: _softColor, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// 오전/오후 휠 — 타이핑 입력은 필요 없어 별도 위젯으로 분리.
class _PeriodWheel extends StatelessWidget {
  final FixedExtentScrollController controller;

  const _PeriodWheel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: _itemExtent,
      squeeze: 1.0,
      useMagnifier: true,
      magnification: 1.25,
      diameterRatio: 1.1,
      backgroundColor: Colors.transparent,
      onSelectedItemChanged: (_) {},
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
      ),
      children: List.generate(2, (i) {
        return Center(
          child: Text(
            i == 0 ? '오전' : '오후',
            style: GoogleFonts.gowunBatang(
              color: _softColor,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }
}

// 시/분 칸 — 평소엔 휠, 입력 중일 땐 음영 박스 + 입력값을 보여준다.
// 스크롤 중에는 setState를 호출하지 않는다 — 휠 자체가 스크롤 위치를 들고 있고,
// 매 프레임 부모 전체를 다시 그리면 스냅 애니메이션이 끊기는 느낌을 준다.
class _TimeWheelSlot extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final int displayOffset;
  final bool looping;
  final bool padTwoDigits;
  final bool editing;
  final String editBuffer;
  final VoidCallback onTap;

  const _TimeWheelSlot({
    required this.controller,
    required this.itemCount,
    required this.displayOffset,
    required this.editing,
    required this.editBuffer,
    required this.onTap,
    this.looping = false,
    this.padTwoDigits = false,
  });

  int get _wrappedSelected =>
      ((controller.selectedItem % itemCount) + itemCount) % itemCount;

  String _label(int i) {
    final value = i + displayOffset;
    return padTwoDigits ? value.toString().padLeft(2, '0') : '$value';
  }

  @override
  Widget build(BuildContext context) {
    if (editing) {
      final displayText = editBuffer.isNotEmpty ? editBuffer : _label(_wrappedSelected);
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _editHighlight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayText,
            style: GoogleFonts.gowunBatang(
              color: _softColor,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CupertinoPicker(
          scrollController: controller,
          itemExtent: _itemExtent,
          looping: looping,
          squeeze: 1.0,
          useMagnifier: true,
          magnification: 1.25,
          diameterRatio: 1.1,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (_) {},
          selectionOverlay: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
          ),
          children: List.generate(itemCount, (i) {
            return Center(
              child: Text(
                _label(i),
                style: GoogleFonts.gowunBatang(
                  color: _softColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
        // CupertinoPicker의 selectionOverlay는 IgnorePointer로 감싸여 탭을 받지 못하므로
        // 가운데 칸 위에 별도의 탭 영역을 겹쳐서 숫자 입력 모드로 전환한다.
        SizedBox(
          height: _itemExtent,
          width: double.infinity,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

// 시스템 키보드 대신 보여주는 전용 숫자 패드.
class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  const _NumPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onDone,
  });

  Widget _cell(Widget child, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.4), width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _digitText(String d) {
    return Text(d, style: GoogleFonts.gowunBatang(color: _softColor, fontSize: 22));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          _cell(_digitText('1'), () => onDigit('1')),
          _cell(_digitText('2'), () => onDigit('2')),
          _cell(_digitText('3'), () => onDigit('3')),
        ]),
        Row(children: [
          _cell(_digitText('4'), () => onDigit('4')),
          _cell(_digitText('5'), () => onDigit('5')),
          _cell(_digitText('6'), () => onDigit('6')),
        ]),
        Row(children: [
          _cell(_digitText('7'), () => onDigit('7')),
          _cell(_digitText('8'), () => onDigit('8')),
          _cell(_digitText('9'), () => onDigit('9')),
        ]),
        Row(children: [
          _cell(const Icon(Icons.backspace_outlined, color: _softColor, size: 20), onBackspace),
          _cell(_digitText('0'), () => onDigit('0')),
          _cell(
            Text(
              '완료',
              style: GoogleFonts.gowunBatang(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onDone,
          ),
        ]),
      ],
    );
  }
}

// 여러 날짜를 탭 또는 드래그로 선택하는 달력 그리드.
// 탭/드래그 모두 동일한 포인터 이벤트(Listener)로 처리해서 제스처 경쟁 없이
// 누른 첫 칸의 선택 상태 반전 방향을 그대로 드래그 중인 칸들에 적용한다.
class _MultiDateCalendar extends StatefulWidget {
  final Set<DateTime> initialSelected;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<Set<DateTime>> onChanged;

  const _MultiDateCalendar({
    required this.initialSelected,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<_MultiDateCalendar> createState() => _MultiDateCalendarState();
}

class _MultiDateCalendarState extends State<_MultiDateCalendar> {
  late Set<DateTime> _selected;
  late DateTime _displayedMonth;

  bool? _dragSelecting;
  DateTime? _lastDragDate;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    final base = _selected.isNotEmpty ? _selected.first : widget.firstDate;
    _displayedMonth = DateTime(base.year, base.month);
  }

  bool _inRange(DateTime date) =>
      !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);

  void _setSelected(DateTime date, bool select) {
    if (!_inRange(date)) return;
    final already = _selected.contains(date);
    if (select == already) return;
    setState(() {
      if (select) {
        _selected.add(date);
      } else {
        _selected.remove(date);
      }
    });
    widget.onChanged(_selected);
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  DateTime? _dateAt(Offset local, double cellSize, DateTime month, int startOffset, int daysInMonth) {
    if (local.dx < 0 || local.dy < 0) return null;
    final col = (local.dx / cellSize).floor();
    final row = (local.dy / cellSize).floor();
    if (col < 0 || col > 6 || row < 0) return null;
    final index = row * 7 + col;
    final day = index - startOffset + 1;
    if (day < 1 || day > daysInMonth) return null;
    return DateTime(month.year, month.month, day);
  }

  void _handlePointer(Offset local, double cellSize, DateTime month, int startOffset, int daysInMonth, {required bool isStart}) {
    final date = _dateAt(local, cellSize, month, startOffset, daysInMonth);
    if (date == null || !_inRange(date)) {
      if (isStart) {
        _dragSelecting = null;
        _lastDragDate = null;
      }
      return;
    }
    if (isStart) {
      _dragSelecting = !_selected.contains(date);
      _lastDragDate = date;
      _setSelected(date, _dragSelecting!);
    } else {
      if (_dragSelecting == null || date == _lastDragDate) return;
      _lastDragDate = date;
      _setSelected(date, _dragSelecting!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = _displayedMonth;
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7; // 일=0, 월=1, ..., 토=6
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((startOffset + daysInMonth) / 7).ceil();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    final canGoPrev = DateTime(month.year, month.month).isAfter(firstMonth);
    final canGoNext = DateTime(month.year, month.month).isBefore(lastMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_left, size: 22, color: canGoPrev ? _softColor : AppColors.divider),
                onPressed: canGoPrev ? () => _changeMonth(-1) : null,
              ),
              Text(
                '${month.year}년 ${month.month}월',
                style: GoogleFonts.gowunBatang(color: _softColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.chevron_right, size: 22, color: canGoNext ? _softColor : AppColors.divider),
                onPressed: canGoNext ? () => _changeMonth(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gowunBatang(fontSize: 11, color: AppColors.textHint),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(builder: (context, constraints) {
            final cellSize = constraints.maxWidth / 7;
            final gridHeight = cellSize * rows;
            return Listener(
              onPointerDown: (e) => _handlePointer(e.localPosition, cellSize, month, startOffset, daysInMonth, isStart: true),
              onPointerMove: (e) => _handlePointer(e.localPosition, cellSize, month, startOffset, daysInMonth, isStart: false),
              onPointerUp: (_) {
                _dragSelecting = null;
                _lastDragDate = null;
              },
              child: SizedBox(
                width: constraints.maxWidth,
                height: gridHeight,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: rows * 7,
                  itemBuilder: (context, index) {
                    final day = index - startOffset + 1;
                    if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
                    final date = DateTime(month.year, month.month, day);
                    final isSelected = _selected.contains(date);
                    final isToday = date == todayOnly;
                    final isDisabled = !_inRange(date);
                    return _CalendarDayCell(
                      day: day,
                      isSelected: isSelected,
                      isToday: isToday,
                      isDisabled: isDisabled,
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  const _CalendarDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDisabled
        ? AppColors.divider
        : (isSelected ? AppColors.background : _softColor);

    Widget cell;
    if (isSelected) {
      cell = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text('$day', style: GoogleFonts.gowunBatang(fontSize: 13, color: textColor)),
      );
    } else if (isToday) {
      cell = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text('$day', style: GoogleFonts.gowunBatang(fontSize: 13, color: textColor)),
      );
    } else {
      cell = SizedBox(
        width: 30,
        height: 30,
        child: Center(child: Text('$day', style: GoogleFonts.gowunBatang(fontSize: 13, color: textColor))),
      );
    }

    return IgnorePointer(
      // 탭/드래그는 부모 Listener가 좌표 기반으로 직접 처리한다 — 셀은 시각 표시만 담당.
      child: Center(child: cell),
    );
  }
}
