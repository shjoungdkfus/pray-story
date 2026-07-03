// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navPrayerLog => '기도 기록';

  @override
  String get navCommunity => '커뮤니티';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsGroupMyInfo => '내 정보';

  @override
  String get settingsMyInfo => '내 정보';

  @override
  String get settingsMyInfoSubtitle => '프로필을 확인하고 수정해요';

  @override
  String get settingsGroupPreferences => '환경설정';

  @override
  String get settingsAppSettings => '앱 설정';

  @override
  String get settingsAppSettingsSubtitle => '알림, 테마, 언어';

  @override
  String get settingsGroupSupport => '지원';

  @override
  String get settingsFeedback => '피드백';

  @override
  String get settingsFeedbackSubtitle => '관리자에게 의견을 보내요';

  @override
  String get settingsGroupAccount => '계정';

  @override
  String get settingsAccount => '계정';

  @override
  String get settingsAccountSubtitle => '로그아웃, 회원 탈퇴';

  @override
  String get appSettingsTitle => '앱 설정';

  @override
  String get appSettingsGroupNotifications => '알림';

  @override
  String get appSettingsNotification => '알림 설정';

  @override
  String get appSettingsNotificationSubtitle => '기도 시간 알림을 관리해요';

  @override
  String get appSettingsGroupDisplay => '화면';

  @override
  String get appSettingsTheme => '화면 테마';

  @override
  String get appSettingsLanguage => '언어';

  @override
  String get themeSheetTitle => '화면 테마';

  @override
  String get themeSheetFootnote => '선택한 테마는 즉시 적용됩니다.';

  @override
  String get languageSheetTitle => '언어';

  @override
  String get languageSheetFootnote => '선택한 언어는 즉시 적용됩니다.';

  @override
  String get themeSystem => '시스템 설정';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get loginTagline => '하나님이 오늘 나를 통해 써 내려가시는 이야기';

  @override
  String get hintEmail => '이메일';

  @override
  String get hintPassword => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get orDivider => '또는';

  @override
  String get kakaoStart => '카카오로 시작하기';

  @override
  String get googleStart => 'Google로 시작하기';

  @override
  String get signupPrompt => '처음이신가요?';

  @override
  String get signupLink => '회원가입';

  @override
  String get errEmptyCredentials => '이메일과 비밀번호를 입력해주세요.';

  @override
  String get errLoginFailed => '이메일 또는 비밀번호를 다시 확인해주세요.';

  @override
  String get errGoogleFailed => 'Google 로그인에 실패했어요. 다시 시도해주세요.';

  @override
  String get errKakaoFailed => '카카오 로그인에 실패했어요. 다시 시도해주세요.';

  @override
  String get signup1Title => '반가워요!\n계정을 만들어볼까요';

  @override
  String get signup1Subtitle => '로그인에 사용할 이메일과 비밀번호를 입력해주세요.';

  @override
  String get labelEmail => '이메일';

  @override
  String get labelPassword => '비밀번호';

  @override
  String get labelPasswordConfirm => '비밀번호 확인';

  @override
  String get hintEmailExample => 'example@email.com';

  @override
  String get hintPasswordMin => '6자 이상';

  @override
  String get hintPasswordAgain => '비밀번호 다시 입력';

  @override
  String get buttonNext => '다음';

  @override
  String get errEmailFormat => '올바른 이메일 형식을 입력해주세요.';

  @override
  String get errPasswordMin => '비밀번호는 6자 이상 입력해주세요.';

  @override
  String get errPasswordMismatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get buttonConfirm => '확인';

  @override
  String get commonSelect => '선택';

  @override
  String get commonNotSet => '선택 안 함';

  @override
  String get profileName => '이름';

  @override
  String get profileNamePlaceholder => '이름 입력';

  @override
  String get profileNameHint => '이름을 입력해주세요';

  @override
  String get profilePhoto => '프로필 사진';

  @override
  String get profileChurch => '교회';

  @override
  String get profileChurchPlaceholder => '교회 선택';

  @override
  String get profileChurchHint => '출석 중인 교회 (선택)';

  @override
  String get profileGender => '성별';

  @override
  String get profileAgeGroup => '연령대';

  @override
  String get profilePrivacyNote => '성별과 연령대 정보는 공동체에 공개되지 않습니다.';

  @override
  String get genderMale => '남자';

  @override
  String get genderFemale => '여자';

  @override
  String get ageUnder10 => '10대 미만';

  @override
  String ageGroup(int decade) {
    return '$decade대';
  }

  @override
  String get birthYearSheetTitle => '연령대 계산을 위해 출생연도를 선택해주세요';

  @override
  String birthYearItem(int year) {
    return '$year년생';
  }

  @override
  String get signup2Title => '환영합니다!\n프로필을 완성해주세요';

  @override
  String get errNameRequired => '이름을 입력해주세요.';

  @override
  String get photoComingSoon => '프로필 사진 기능은 곧 제공될 예정이에요. 지금은 이름으로 만든 아바타가 보여요.';

  @override
  String get signup3Title => '거의 다 왔어요!\n화면 테마를 골라주세요';

  @override
  String get signup3Subtitle => '나중에 설정에서 언제든 바꿀 수 있어요.';

  @override
  String get signup3SystemOption => '시스템 설정 따르기';

  @override
  String get signup3StartButton => 'PrayStory 시작하기';

  @override
  String get errAlreadyRegistered => '이미 가입된 이메일입니다. 로그인해주세요.';

  @override
  String get errSignupFailed => '가입 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.';

  @override
  String get signupProfileIncomplete => '계정이 만들어졌어요. 프로필은 설정에서 완성할 수 있어요.';
}
