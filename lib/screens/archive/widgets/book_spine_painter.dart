import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BookSpineState { completed, current, future }

class BookSpinePainter extends CustomPainter {
  final Color baseColor;
  final BookSpineState state;

  BookSpinePainter({required this.baseColor, required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (state == BookSpineState.future) {
      final outline = Paint()
        ..color = AppColors.divider.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(rect.deflate(0.5), outline);
      return;
    }

    final opacity = state == BookSpineState.current ? 0.55 : 1.0;

    canvas.drawRect(rect, Paint()..color = baseColor.withValues(alpha: opacity));

    // 우측 가장자리 음영선
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3, 0, 3, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    final gold = AppColors.goldColor.withValues(alpha: opacity);
    final goldLine = Paint()
      ..color = gold
      ..strokeWidth = 1.2;

    final topY1 = size.height * 0.12;
    final topY2 = size.height * 0.17;
    final botY1 = size.height * 0.83;
    final botY2 = size.height * 0.88;
    for (final y in [topY1, topY2, botY1, botY2]) {
      canvas.drawLine(Offset(6, y), Offset(size.width - 6, y), goldLine);
    }

    final dotPaint = Paint()..color = gold;
    for (final o in [
      Offset(6, topY1),
      Offset(size.width - 6, topY1),
      Offset(6, botY2),
      Offset(size.width - 6, botY2),
    ]) {
      canvas.drawCircle(o, 1.6, dotPaint);
    }

    if (state == BookSpineState.current) {
      _drawDashedRect(canvas, rect.deflate(1.5), gold);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;

    void drawDashedLine(Offset start, Offset end) {
      final totalLength = (end - start).distance;
      if (totalLength == 0) return;
      final dir = (end - start) / totalLength;
      double covered = 0;
      while (covered < totalLength) {
        final segEnd =
            covered + dashWidth < totalLength ? covered + dashWidth : totalLength;
        canvas.drawLine(start + dir * covered, start + dir * segEnd, paint);
        covered += dashWidth + dashSpace;
      }
    }

    drawDashedLine(rect.topLeft, rect.topRight);
    drawDashedLine(rect.topRight, rect.bottomRight);
    drawDashedLine(rect.bottomRight, rect.bottomLeft);
    drawDashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant BookSpinePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor || oldDelegate.state != state;
}
