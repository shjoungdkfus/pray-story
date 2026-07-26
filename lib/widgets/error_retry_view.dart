import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// 비동기 로드 실패 시 공통으로 쓰는 에러 표시.
///
/// 종전엔 각 화면이 `Text(l.commonError(e.toString()))`로 예외 원문을 그대로
/// 노출하고 재시도 수단도 없었다(PS-UI-05·PS-UI-06). 이 위젯은
/// ① 사용자 언어로 된 일반 문구만 보여주고 ② 재시도 버튼을 제공한다.
/// 진단용 원문은 화면이 아니라 `debugPrint`로만 남긴다.
class ErrorRetryView extends StatelessWidget {
  /// 표시할 문구. 없으면 공통 문구(`commonLoadFailed`)를 쓴다.
  final String? message;
  final VoidCallback onRetry;

  /// 리스트 안에 끼워 넣을 때처럼 세로 공간이 좁은 곳에서 여백을 줄이는 용도.
  final bool compact;

  const ErrorRetryView({
    super.key,
    required this.onRetry,
    this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: compact ? 16 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: compact ? 28 : 40,
              color: AppColors.textHint,
            ),
            SizedBox(height: compact ? 8 : 12),
            Text(
              message ?? l.commonLoadFailed,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                color: AppColors.textHint,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            SizedBox(height: compact ? 6 : 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded,
                  size: 18, color: AppColors.accentText),
              label: Text(
                l.buttonRetry,
                style: GoogleFonts.notoSansKr(
                  color: AppColors.accentText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size(88, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
