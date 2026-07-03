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

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get profileNamePlaceholder;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get profileNameHint;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @profileChurch.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get profileChurch;

  /// No description provided for @profileChurchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select church'**
  String get profileChurchPlaceholder;

  /// No description provided for @profileChurchHint.
  ///
  /// In en, this message translates to:
  /// **'Church you attend (optional)'**
  String get profileChurchHint;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get profileAgeGroup;

  /// No description provided for @profilePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your gender and age group are not shared with the community.'**
  String get profilePrivacyNote;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @ageUnder10.
  ///
  /// In en, this message translates to:
  /// **'Under 10'**
  String get ageUnder10;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'{decade}s'**
  String ageGroup(int decade);

  /// No description provided for @birthYearSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your birth year to calculate your age group'**
  String get birthYearSheetTitle;

  /// No description provided for @birthYearItem.
  ///
  /// In en, this message translates to:
  /// **'Born {year}'**
  String birthYearItem(int year);

  /// No description provided for @signup2Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome!\nComplete your profile'**
  String get signup2Title;

  /// No description provided for @errNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get errNameRequired;

  /// No description provided for @photoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile photo is coming soon. For now, an avatar made from your name is shown.'**
  String get photoComingSoon;

  /// No description provided for @signup3Title.
  ///
  /// In en, this message translates to:
  /// **'Almost there!\nPick a theme'**
  String get signup3Title;

  /// No description provided for @signup3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it anytime in settings.'**
  String get signup3Subtitle;

  /// No description provided for @signup3SystemOption.
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get signup3SystemOption;

  /// No description provided for @signup3StartButton.
  ///
  /// In en, this message translates to:
  /// **'Start PrayStory'**
  String get signup3StartButton;

  /// No description provided for @errAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please log in.'**
  String get errAlreadyRegistered;

  /// No description provided for @errSignupFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during sign-up. Please try again shortly.'**
  String get errSignupFailed;

  /// No description provided for @signupProfileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Your account was created. You can complete your profile in settings.'**
  String get signupProfileIncomplete;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'The record was deleted.'**
  String get recordDeleted;

  /// No description provided for @errDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while deleting.'**
  String get errDeleteFailed;

  /// No description provided for @errSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while saving. Please try again.'**
  String get errSaveFailed;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @homeToToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToToday;

  /// No description provided for @homeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get homeDefaultName;

  /// No description provided for @homeStoryOf.
  ///
  /// In en, this message translates to:
  /// **'Story of {name}'**
  String homeStoryOf(String name);

  /// No description provided for @homeEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to record\nthe story God has written\nin your life today.'**
  String get homeEmptyToday;

  /// No description provided for @homeEmptyOther.
  ///
  /// In en, this message translates to:
  /// **'Record the story\nof this day.'**
  String get homeEmptyOther;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by date, prayer title, or keyword'**
  String get searchHint;

  /// No description provided for @searchUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get searchUntitled;

  /// No description provided for @writeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get writeDeleteTitle;

  /// No description provided for @writeDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this prayer record?'**
  String get writeDeleteMessage;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @writeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated.'**
  String get writeUpdated;

  /// No description provided for @writeSavedToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s page has been saved.'**
  String get writeSavedToday;

  /// No description provided for @writeSaved.
  ///
  /// In en, this message translates to:
  /// **'Your prayer record has been saved.'**
  String get writeSaved;

  /// No description provided for @writeTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get writeTitleEdit;

  /// No description provided for @writeTitleToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s record'**
  String get writeTitleToday;

  /// No description provided for @writeTitleOther.
  ///
  /// In en, this message translates to:
  /// **'Prayer record'**
  String get writeTitleOther;

  /// No description provided for @writeSubmitEdit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get writeSubmitEdit;

  /// No description provided for @writeSubmitToday.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get writeSubmitToday;

  /// No description provided for @writeSubmitOther.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get writeSubmitOther;

  /// No description provided for @writeHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer title'**
  String get writeHintTitle;

  /// No description provided for @writeHintContent.
  ///
  /// In en, this message translates to:
  /// **'Write the story you want to bring before God.'**
  String get writeHintContent;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'My Prayer Log'**
  String get recordTitle;

  /// No description provided for @statUnitDays.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get statUnitDays;

  /// No description provided for @statUnitCount.
  ///
  /// In en, this message translates to:
  /// **''**
  String get statUnitCount;

  /// No description provided for @statThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statThisMonth;

  /// No description provided for @statAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get statAnswered;

  /// No description provided for @recordPrayerTitles.
  ///
  /// In en, this message translates to:
  /// **'Prayer Titles'**
  String get recordPrayerTitles;

  /// No description provided for @recordRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Records'**
  String get recordRecent;

  /// No description provided for @recordUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get recordUntitled;

  /// No description provided for @recordLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String recordLoadError(Object error);

  /// No description provided for @recordWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week}, {month}'**
  String recordWeekLabel(int week, String month);
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
