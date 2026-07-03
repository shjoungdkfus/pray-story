import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @navPrayerLog.
  ///
  /// In en, this message translates to:
  /// **'Prayer Log'**
  String get navPrayerLog;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupMyInfo.
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get settingsGroupMyInfo;

  /// No description provided for @settingsMyInfo.
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get settingsMyInfo;

  /// No description provided for @settingsMyInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and edit your profile'**
  String get settingsMyInfoSubtitle;

  /// No description provided for @settingsGroupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsGroupPreferences;

  /// No description provided for @settingsAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsAppSettings;

  /// No description provided for @settingsAppSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications, theme, language'**
  String get settingsAppSettingsSubtitle;

  /// No description provided for @settingsGroupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsGroupSupport;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback to the admin'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsGroupAccount;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log out, delete account'**
  String get settingsAccountSubtitle;

  /// No description provided for @appSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettingsTitle;

  /// No description provided for @appSettingsGroupNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get appSettingsGroupNotifications;

  /// No description provided for @appSettingsNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get appSettingsNotification;

  /// No description provided for @appSettingsNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage prayer time reminders'**
  String get appSettingsNotificationSubtitle;

  /// No description provided for @appSettingsGroupDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get appSettingsGroupDisplay;

  /// No description provided for @appSettingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appSettingsTheme;

  /// No description provided for @appSettingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appSettingsLanguage;

  /// No description provided for @themeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSheetTitle;

  /// No description provided for @themeSheetFootnote.
  ///
  /// In en, this message translates to:
  /// **'The selected theme applies immediately.'**
  String get themeSheetFootnote;

  /// No description provided for @languageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSheetTitle;

  /// No description provided for @languageSheetFootnote.
  ///
  /// In en, this message translates to:
  /// **'The selected language applies immediately.'**
  String get languageSheetFootnote;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'The story God writes through me today'**
  String get loginTagline;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hintEmail;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get hintPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @kakaoStart.
  ///
  /// In en, this message translates to:
  /// **'Continue with Kakao'**
  String get kakaoStart;

  /// No description provided for @googleStart.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleStart;

  /// No description provided for @signupPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get signupPrompt;

  /// No description provided for @signupLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupLink;

  /// No description provided for @errEmptyCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get errEmptyCredentials;

  /// No description provided for @errLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Please check your email or password.'**
  String get errLoginFailed;

  /// No description provided for @errGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get errGoogleFailed;

  /// No description provided for @errKakaoFailed.
  ///
  /// In en, this message translates to:
  /// **'Kakao sign-in failed. Please try again.'**
  String get errKakaoFailed;

  /// No description provided for @signup1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome!\nLet\'s create your account'**
  String get signup1Title;

  /// No description provided for @signup1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email and password you\'ll use to log in.'**
  String get signup1Subtitle;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get labelPasswordConfirm;

  /// No description provided for @hintEmailExample.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get hintEmailExample;

  /// No description provided for @hintPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'6+ characters'**
  String get hintPasswordMin;

  /// No description provided for @hintPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get hintPasswordAgain;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @errEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errEmailFormat;

  /// No description provided for @errPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errPasswordMin;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errPasswordMismatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
