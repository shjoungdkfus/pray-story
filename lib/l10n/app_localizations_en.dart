// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navPrayerLog => 'Prayer Log';

  @override
  String get navCommunity => 'Community';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupMyInfo => 'My Info';

  @override
  String get settingsMyInfo => 'My Info';

  @override
  String get settingsMyInfoSubtitle => 'View and edit your profile';

  @override
  String get settingsGroupPreferences => 'Preferences';

  @override
  String get settingsAppSettings => 'App Settings';

  @override
  String get settingsAppSettingsSubtitle => 'Notifications, theme, language';

  @override
  String get settingsGroupSupport => 'Support';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Send feedback to the admin';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAccountSubtitle => 'Log out, delete account';

  @override
  String get appSettingsTitle => 'App Settings';

  @override
  String get appSettingsGroupNotifications => 'Notifications';

  @override
  String get appSettingsNotification => 'Notification Settings';

  @override
  String get appSettingsNotificationSubtitle => 'Manage prayer time reminders';

  @override
  String get appSettingsGroupDisplay => 'Display';

  @override
  String get appSettingsTheme => 'Theme';

  @override
  String get appSettingsLanguage => 'Language';

  @override
  String get themeSheetTitle => 'Theme';

  @override
  String get themeSheetFootnote => 'The selected theme applies immediately.';

  @override
  String get languageSheetTitle => 'Language';

  @override
  String get languageSheetFootnote =>
      'The selected language applies immediately.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get loginTagline => 'The story God writes through me today';

  @override
  String get hintEmail => 'Email';

  @override
  String get hintPassword => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get orDivider => 'or';

  @override
  String get kakaoStart => 'Continue with Kakao';

  @override
  String get googleStart => 'Continue with Google';

  @override
  String get signupPrompt => 'New here?';

  @override
  String get signupLink => 'Sign Up';

  @override
  String get errEmptyCredentials => 'Please enter your email and password.';

  @override
  String get errLoginFailed => 'Please check your email or password.';

  @override
  String get errGoogleFailed => 'Google sign-in failed. Please try again.';

  @override
  String get errKakaoFailed => 'Kakao sign-in failed. Please try again.';

  @override
  String get signup1Title => 'Welcome!\nLet\'s create your account';

  @override
  String get signup1Subtitle =>
      'Enter the email and password you\'ll use to log in.';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelPasswordConfirm => 'Confirm Password';

  @override
  String get hintEmailExample => 'example@email.com';

  @override
  String get hintPasswordMin => '6+ characters';

  @override
  String get hintPasswordAgain => 'Re-enter password';

  @override
  String get buttonNext => 'Next';

  @override
  String get errEmailFormat => 'Please enter a valid email address.';

  @override
  String get errPasswordMin => 'Password must be at least 6 characters.';

  @override
  String get errPasswordMismatch => 'Passwords do not match.';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get profileName => 'Name';

  @override
  String get profileNamePlaceholder => 'Enter name';

  @override
  String get profileNameHint => 'Please enter your name';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get profileChurch => 'Church';

  @override
  String get profileChurchPlaceholder => 'Select church';

  @override
  String get profileChurchHint => 'Church you attend (optional)';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileAgeGroup => 'Age Group';

  @override
  String get profilePrivacyNote =>
      'Your gender and age group are not shared with the community.';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get ageUnder10 => 'Under 10';

  @override
  String ageGroup(int decade) {
    return '${decade}s';
  }

  @override
  String get birthYearSheetTitle =>
      'Select your birth year to calculate your age group';

  @override
  String birthYearItem(int year) {
    return 'Born $year';
  }

  @override
  String get signup2Title => 'Welcome!\nComplete your profile';

  @override
  String get errNameRequired => 'Please enter your name.';

  @override
  String get photoComingSoon =>
      'Profile photo is coming soon. For now, an avatar made from your name is shown.';

  @override
  String get signup3Title => 'Almost there!\nPick a theme';

  @override
  String get signup3Subtitle => 'You can change it anytime in settings.';

  @override
  String get signup3SystemOption => 'Follow system settings';

  @override
  String get signup3StartButton => 'Start PrayStory';

  @override
  String get errAlreadyRegistered =>
      'This email is already registered. Please log in.';

  @override
  String get errSignupFailed =>
      'Something went wrong during sign-up. Please try again shortly.';

  @override
  String get signupProfileIncomplete =>
      'Your account was created. You can complete your profile in settings.';
}
