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

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonError(Object error);

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Groups'**
  String get communityTitle;

  /// No description provided for @communitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share prayers with family and friends'**
  String get communitySubtitle;

  /// No description provided for @communityCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get communityCreateGroup;

  /// No description provided for @communityInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get communityInviteCode;

  /// No description provided for @communityMyGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get communityMyGroups;

  /// No description provided for @communityGroupDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'A group praying together'**
  String get communityGroupDefaultDesc;

  /// No description provided for @communityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get communityEmptyTitle;

  /// No description provided for @communityEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first group to\npray with family and friends'**
  String get communityEmptySubtitle;

  /// No description provided for @createGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroupTitle;

  /// No description provided for @createGroupHeading.
  ///
  /// In en, this message translates to:
  /// **'Create a group\nto pray together'**
  String get createGroupHeading;

  /// No description provided for @createGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Share prayer letters with family and\nfriends using an invite code'**
  String get createGroupDesc;

  /// No description provided for @createGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get createGroupNameLabel;

  /// No description provided for @createGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family prayer room, cell group, ...'**
  String get createGroupNameHint;

  /// No description provided for @createGroupJoinLink.
  ///
  /// In en, this message translates to:
  /// **'Join a group with an invite code'**
  String get createGroupJoinLink;

  /// No description provided for @createGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Created the group {name}'**
  String createGroupSuccess(String name);

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get joinGroupHeading;

  /// No description provided for @joinGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code you received from the group owner'**
  String get joinGroupDesc;

  /// No description provided for @joinGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinGroupButton;

  /// No description provided for @joinGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Joined the group {name}'**
  String joinGroupSuccess(String name);

  /// No description provided for @inviteHeading.
  ///
  /// In en, this message translates to:
  /// **'Invite to my group'**
  String get inviteHeading;

  /// No description provided for @inviteDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and family to\nshare prayer letters together'**
  String get inviteDesc;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCodeCopied;

  /// No description provided for @inviteShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get inviteShareButton;

  /// No description provided for @inviteShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s pray together on PrayStory!\nGroup: {name}\nInvite code: {code}'**
  String inviteShareMessage(String name, String code);

  /// No description provided for @groupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfoTitle;

  /// No description provided for @groupLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get groupLeave;

  /// No description provided for @groupLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group?'**
  String get groupLeaveConfirm;

  /// No description provided for @groupLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeaveAction;

  /// No description provided for @groupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get groupDelete;

  /// No description provided for @groupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This group and all its letters will be deleted.\nAre you sure?'**
  String get groupDeleteConfirm;

  /// No description provided for @groupMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String groupMemberCount(int count);

  /// No description provided for @groupMemberCountMax.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} members'**
  String groupMemberCountMax(int count, int max);

  /// No description provided for @groupInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get groupInvite;

  /// No description provided for @groupCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String groupCreatedOn(String date);

  /// No description provided for @groupRename.
  ///
  /// In en, this message translates to:
  /// **'Change group name'**
  String get groupRename;

  /// No description provided for @groupRenameHint.
  ///
  /// In en, this message translates to:
  /// **'New group name'**
  String get groupRenameHint;

  /// No description provided for @buttonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get buttonChange;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @noticeWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Notice'**
  String get noticeWriteTitle;

  /// No description provided for @buttonPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get buttonPost;

  /// No description provided for @noticeBadge.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get noticeBadge;

  /// No description provided for @noticeDeliveredTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {name} members'**
  String noticeDeliveredTo(String name);

  /// No description provided for @noticeHint.
  ///
  /// In en, this message translates to:
  /// **'Write the notice to share with the group'**
  String get noticeHint;

  /// No description provided for @noticePosted.
  ///
  /// In en, this message translates to:
  /// **'Notice posted'**
  String get noticePosted;

  /// No description provided for @letterSent.
  ///
  /// In en, this message translates to:
  /// **'Your prayer letter was sent'**
  String get letterSent;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get visibilityPrivate;

  /// No description provided for @visibilityGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get visibilityGroup;

  /// No description provided for @visibilityCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get visibilityCommunity;

  /// No description provided for @letterForRecipient.
  ///
  /// In en, this message translates to:
  /// **'A letter for {name}'**
  String letterForRecipient(String name);

  /// No description provided for @prayForHeading.
  ///
  /// In en, this message translates to:
  /// **'Send a prayer letter\nto someone dear'**
  String get prayForHeading;

  /// No description provided for @prayForDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter a name to write a\nprayer letter for that person'**
  String get prayForDesc;

  /// No description provided for @prayForRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get prayForRecipientLabel;

  /// No description provided for @prayForRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mom, my friend Minjun, ...'**
  String get prayForRecipientHint;

  /// No description provided for @prayForButton.
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get prayForButton;

  /// No description provided for @groupHeaderFriends.
  ///
  /// In en, this message translates to:
  /// **'{count} friends praying together'**
  String groupHeaderFriends(int count);

  /// No description provided for @groupAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get groupAdd;

  /// No description provided for @tabNotice.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get tabNotice;

  /// No description provided for @tabLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get tabLetters;

  /// No description provided for @tabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get tabMembers;

  /// No description provided for @groupWriteLetter.
  ///
  /// In en, this message translates to:
  /// **'Write a letter'**
  String get groupWriteLetter;

  /// No description provided for @groupPostNotice.
  ///
  /// In en, this message translates to:
  /// **'Post a notice'**
  String get groupPostNotice;

  /// No description provided for @groupInviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get groupInviteMember;

  /// No description provided for @groupEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Change group description'**
  String get groupEditDesc;

  /// No description provided for @groupDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your group in one line'**
  String get groupDescHint;

  /// No description provided for @groupChangeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get groupChangeIcon;

  /// No description provided for @groupManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get groupManageMembers;

  /// No description provided for @groupIconPick.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get groupIconPick;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @groupLeaveOwnerConfirm.
  ///
  /// In en, this message translates to:
  /// **'If the owner leaves, the group and all its posts are deleted.\nAre you sure you want to leave?'**
  String get groupLeaveOwnerConfirm;

  /// No description provided for @noticeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notices yet'**
  String get noticeEmptyTitle;

  /// No description provided for @noticeEmptyOwner.
  ///
  /// In en, this message translates to:
  /// **'Tap Add to post the first notice'**
  String get noticeEmptyOwner;

  /// No description provided for @noticeEmptyMember.
  ///
  /// In en, this message translates to:
  /// **'Wait for a notice from the owner'**
  String get noticeEmptyMember;

  /// No description provided for @noticeLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notices'**
  String get noticeLoadErrorTitle;

  /// No description provided for @noticeLoadErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check that community_v2.sql has been run'**
  String get noticeLoadErrorSubtitle;

  /// No description provided for @letterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No letters shared yet'**
  String get letterEmptyTitle;

  /// No description provided for @letterEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Add to write the first prayer letter'**
  String get letterEmptySubtitle;

  /// No description provided for @letterToRecipient.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String letterToRecipient(String name);

  /// No description provided for @prayTogetherCount.
  ///
  /// In en, this message translates to:
  /// **'🙏 {count} prayed together'**
  String prayTogetherCount(int count);

  /// No description provided for @prayTogetherDesc.
  ///
  /// In en, this message translates to:
  /// **'These are the people who prayed with you'**
  String get prayTogetherDesc;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @prayedTogether.
  ///
  /// In en, this message translates to:
  /// **'Prayed'**
  String get prayedTogether;

  /// No description provided for @prayTogether.
  ///
  /// In en, this message translates to:
  /// **'Pray Together'**
  String get prayTogether;

  /// No description provided for @anonymousFriend.
  ///
  /// In en, this message translates to:
  /// **'An anonymous friend'**
  String get anonymousFriend;

  /// No description provided for @memberKickTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get memberKickTitle;

  /// No description provided for @memberKickConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the group?'**
  String memberKickConfirm(String name);

  /// No description provided for @memberDefault.
  ///
  /// In en, this message translates to:
  /// **'this member'**
  String get memberDefault;

  /// No description provided for @memberKickAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get memberKickAction;

  /// No description provided for @timeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeToday;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timeDaysAgo(int days);

  /// No description provided for @timeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get timeTomorrow;

  /// No description provided for @notifSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a daily prayer reminder at the times you set.'**
  String get notifSettingsInfo;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get notifEmptyTitle;

  /// No description provided for @notifDailyGroup.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer Reminders'**
  String get notifDailyGroup;

  /// No description provided for @notifAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get notifAddButton;

  /// No description provided for @feedbackContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message.'**
  String get feedbackContentRequired;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Let us know your thoughts or ideas for improving the app. Your feedback goes straight to the admin.'**
  String get feedbackDesc;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackContentLabel;

  /// No description provided for @feedbackContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write freely about anything on your mind.'**
  String get feedbackContentHint;

  /// No description provided for @feedbackSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSendButton;

  /// No description provided for @feedbackSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback. It was delivered.'**
  String get feedbackSentSuccess;

  /// No description provided for @feedbackSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Please try emailing instead.'**
  String get feedbackSendFailed;

  /// No description provided for @feedbackEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Send by email'**
  String get feedbackEmailButton;

  /// No description provided for @feedbackEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open a mail app.'**
  String get feedbackEmailFailed;

  /// No description provided for @feedbackSubjectPrefix.
  ///
  /// In en, this message translates to:
  /// **'[PrayStory Feedback]'**
  String get feedbackSubjectPrefix;

  /// No description provided for @feedbackEmailFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get feedbackEmailFrom;

  /// No description provided for @feedbackEmailVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get feedbackEmailVersion;

  /// No description provided for @feedbackCatBug.
  ///
  /// In en, this message translates to:
  /// **'Bug report'**
  String get feedbackCatBug;

  /// No description provided for @feedbackCatFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature request'**
  String get feedbackCatFeature;

  /// No description provided for @feedbackCatInquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiry'**
  String get feedbackCatInquiry;

  /// No description provided for @feedbackCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackCatOther;

  /// No description provided for @accountLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get accountLogout;

  /// No description provided for @accountLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get accountLogoutConfirm;

  /// No description provided for @accountWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountWithdraw;

  /// No description provided for @accountWithdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will deactivate it and you won\'t be able to log in again.\nAre you sure you want to continue?'**
  String get accountWithdrawConfirm;

  /// No description provided for @accountWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountWithdrawButton;

  /// No description provided for @accountWithdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while deleting your account. Please try again.'**
  String get accountWithdrawFailed;

  /// No description provided for @accountWithdrawNote.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deactivated. If you\'d like your prayer records permanently deleted, please contact us via Feedback.'**
  String get accountWithdrawNote;

  /// No description provided for @profileEditHeading.
  ///
  /// In en, this message translates to:
  /// **'Update your profile\nwith the info you\'d like'**
  String get profileEditHeading;

  /// No description provided for @profileEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get profileEditSaved;

  /// No description provided for @profileEditSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while saving. Please try again.'**
  String get profileEditSaveFailed;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileEditButton;

  /// No description provided for @settingsNoNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Set your name'**
  String get settingsNoNamePlaceholder;

  /// No description provided for @fontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get fontSizeTitle;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeSample.
  ///
  /// In en, this message translates to:
  /// **'Aa'**
  String get fontSizeSample;

  /// No description provided for @notifPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get notifPickerTitle;

  /// No description provided for @buttonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get buttonDone;

  /// No description provided for @dateSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get dateSelectTitle;

  /// No description provided for @dateSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select one date, or drag to select several at once.'**
  String get dateSelectHint;

  /// No description provided for @dateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get dateNotSelected;

  /// No description provided for @dateAndOthers.
  ///
  /// In en, this message translates to:
  /// **'{first} +{count} more · {total} days selected'**
  String dateAndOthers(String first, int count, int total);

  /// No description provided for @periodAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get periodAm;

  /// No description provided for @periodPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get periodPm;
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
