/// 앱 버전 표기 단일 출처.
///
/// 종전엔 설정 화면·피드백 DB·피드백 메일 3곳에 버전 문자열이 각각
/// 하드코딩돼 있어(`pubspec.yaml` bump 시 자동 갱신되지 않음) 피드백 테이블에
/// 잘못된 버전이 쌓일 수 있었다(PS-UI-11).
///
/// ⚠️ **릴리스 절차:** `pubspec.yaml`의 `version:`을 올릴 때 아래 두 상수도 함께 올린다.
/// (`docs/deploy_checklist.md`의 버전 bump 항목 참조)
class AppInfo {
  AppInfo._();

  /// pubspec.yaml `version:`의 앞부분 (versionName)
  static const String versionName = '1.0.0';

  /// pubspec.yaml `version:`의 뒷부분 (versionCode)
  static const String buildNumber = '3';

  /// `1.0.0+1` 형태 — 피드백 등 진단용 기록에 쓴다.
  static const String fullVersion = '$versionName+$buildNumber';

  /// `PrayStory · v1.0.0` 형태 — 설정 화면 하단 표기.
  static const String displayLabel = 'PrayStory · v$versionName';
}
