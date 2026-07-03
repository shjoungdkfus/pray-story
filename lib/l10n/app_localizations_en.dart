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

  @override
  String get recordDeleted => 'The record was deleted.';

  @override
  String get errDeleteFailed => 'Something went wrong while deleting.';

  @override
  String get errSaveFailed =>
      'Something went wrong while saving. Please try again.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String get homeToToday => 'Today';

  @override
  String get homeDefaultName => 'Me';

  @override
  String homeStoryOf(String name) {
    return 'Story of $name';
  }

  @override
  String get homeEmptyToday =>
      'Take a moment to record\nthe story God has written\nin your life today.';

  @override
  String get homeEmptyOther => 'Record the story\nof this day.';

  @override
  String get searchHint => 'Search by date, prayer title, or keyword';

  @override
  String get searchUntitled => '(Untitled)';

  @override
  String get writeDeleteTitle => 'Delete record';

  @override
  String get writeDeleteMessage => 'Delete this prayer record?';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get writeUpdated => 'Updated.';

  @override
  String get writeSavedToday => 'Today\'s page has been saved.';

  @override
  String get writeSaved => 'Your prayer record has been saved.';

  @override
  String get writeTitleEdit => 'Edit record';

  @override
  String get writeTitleToday => 'Today\'s record';

  @override
  String get writeTitleOther => 'Prayer record';

  @override
  String get writeSubmitEdit => 'Update';

  @override
  String get writeSubmitToday => 'Save';

  @override
  String get writeSubmitOther => 'Save';

  @override
  String get writeHintTitle => 'Prayer title';

  @override
  String get writeHintContent =>
      'Write the story you want to bring before God.';

  @override
  String get recordTitle => 'My Prayer Log';

  @override
  String get statUnitDays => 'd';

  @override
  String get statUnitCount => '';

  @override
  String get statThisMonth => 'This month';

  @override
  String get statAnswered => 'Answered';

  @override
  String get recordPrayerTitles => 'Prayer Titles';

  @override
  String get recordRecent => 'Recent Records';

  @override
  String get recordUntitled => 'Untitled';

  @override
  String recordLoadError(Object error) {
    return 'Error: $error';
  }

  @override
  String recordWeekLabel(int week, String month) {
    return 'Week $week, $month';
  }

  @override
  String commonError(Object error) {
    return 'Error: $error';
  }

  @override
  String get communityTitle => 'Prayer Groups';

  @override
  String get communitySubtitle => 'Share prayers with family and friends';

  @override
  String get communityCreateGroup => 'Create Group';

  @override
  String get communityInviteCode => 'Invite Code';

  @override
  String get communityMyGroups => 'My Groups';

  @override
  String get communityGroupDefaultDesc => 'A group praying together';

  @override
  String get communityEmptyTitle => 'No groups yet';

  @override
  String get communityEmptySubtitle =>
      'Create your first group to\npray with family and friends';

  @override
  String get createGroupTitle => 'Create Group';

  @override
  String get createGroupHeading => 'Create a group\nto pray together';

  @override
  String get createGroupDesc =>
      'Share prayer letters with family and\nfriends using an invite code';

  @override
  String get createGroupNameLabel => 'Group name';

  @override
  String get createGroupNameHint => 'e.g. Family prayer room, cell group, ...';

  @override
  String get createGroupJoinLink => 'Join a group with an invite code';

  @override
  String createGroupSuccess(String name) {
    return 'Created the group $name';
  }

  @override
  String get joinGroupTitle => 'Join Group';

  @override
  String get joinGroupHeading => 'Enter invite code';

  @override
  String get joinGroupDesc =>
      'Enter the invite code you received from the group owner';

  @override
  String get joinGroupButton => 'Join';

  @override
  String joinGroupSuccess(String name) {
    return 'Joined the group $name';
  }

  @override
  String get inviteHeading => 'Invite to my group';

  @override
  String get inviteDesc =>
      'Invite friends and family to\nshare prayer letters together';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get inviteShareButton => 'Share invite link';

  @override
  String inviteShareMessage(String name, String code) {
    return 'Let\'s pray together on PrayStory!\nGroup: $name\nInvite code: $code';
  }

  @override
  String get groupInfoTitle => 'Group Info';

  @override
  String get groupLeave => 'Leave Group';

  @override
  String get groupLeaveConfirm => 'Are you sure you want to leave this group?';

  @override
  String get groupLeaveAction => 'Leave';

  @override
  String get groupDelete => 'Delete Group';

  @override
  String get groupDeleteConfirm =>
      'This group and all its letters will be deleted.\nAre you sure?';

  @override
  String groupMemberCount(int count) {
    return '$count members';
  }

  @override
  String groupMemberCountMax(int count, int max) {
    return '$count / $max members';
  }

  @override
  String get groupInvite => 'Invite';

  @override
  String groupCreatedOn(String date) {
    return 'Created on $date';
  }

  @override
  String get groupRename => 'Change group name';

  @override
  String get groupRenameHint => 'New group name';

  @override
  String get buttonChange => 'Change';

  @override
  String get roleOwner => 'Owner';

  @override
  String get noticeWriteTitle => 'Post Notice';

  @override
  String get buttonPost => 'Post';

  @override
  String get noticeBadge => 'Notice';

  @override
  String noticeDeliveredTo(String name) {
    return 'Sent to $name members';
  }

  @override
  String get noticeHint => 'Write the notice to share with the group';

  @override
  String get noticePosted => 'Notice posted';

  @override
  String get letterSent => 'Your prayer letter was sent';

  @override
  String get visibilityPrivate => 'Only me';

  @override
  String get visibilityGroup => 'Group';

  @override
  String get visibilityCommunity => 'Community';

  @override
  String letterForRecipient(String name) {
    return 'A letter for $name';
  }

  @override
  String get prayForHeading => 'Send a prayer letter\nto someone dear';

  @override
  String get prayForDesc =>
      'Enter a name to write a\nprayer letter for that person';

  @override
  String get prayForRecipientLabel => 'Recipient';

  @override
  String get prayForRecipientHint => 'e.g. Mom, my friend Minjun, ...';

  @override
  String get prayForButton => 'Write a letter';

  @override
  String groupHeaderFriends(int count) {
    return '$count friends praying together';
  }

  @override
  String get groupAdd => 'Add';

  @override
  String get tabNotice => 'Notices';

  @override
  String get tabLetters => 'Letters';

  @override
  String get tabMembers => 'Members';

  @override
  String get groupWriteLetter => 'Write a letter';

  @override
  String get groupPostNotice => 'Post a notice';

  @override
  String get groupInviteMember => 'Invite members';

  @override
  String get groupEditDesc => 'Change group description';

  @override
  String get groupDescHint => 'Describe your group in one line';

  @override
  String get groupChangeIcon => 'Change icon';

  @override
  String get groupManageMembers => 'Manage members';

  @override
  String get groupIconPick => 'Choose an icon';

  @override
  String get buttonSave => 'Save';

  @override
  String get groupLeaveOwnerConfirm =>
      'If the owner leaves, the group and all its posts are deleted.\nAre you sure you want to leave?';

  @override
  String get noticeEmptyTitle => 'No notices yet';

  @override
  String get noticeEmptyOwner => 'Tap Add to post the first notice';

  @override
  String get noticeEmptyMember => 'Wait for a notice from the owner';

  @override
  String get noticeLoadErrorTitle => 'Couldn\'t load notices';

  @override
  String get noticeLoadErrorSubtitle =>
      'Check that community_v2.sql has been run';

  @override
  String get letterEmptyTitle => 'No letters shared yet';

  @override
  String get letterEmptySubtitle => 'Tap Add to write the first prayer letter';

  @override
  String letterToRecipient(String name) {
    return 'To $name';
  }

  @override
  String prayTogetherCount(int count) {
    return '🙏 $count prayed together';
  }

  @override
  String get prayTogetherDesc => 'These are the people who prayed with you';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get prayedTogether => 'Prayed';

  @override
  String get prayTogether => 'Pray Together';

  @override
  String get anonymousFriend => 'An anonymous friend';

  @override
  String get memberKickTitle => 'Remove member';

  @override
  String memberKickConfirm(String name) {
    return 'Remove $name from the group?';
  }

  @override
  String get memberDefault => 'this member';

  @override
  String get memberKickAction => 'Remove';

  @override
  String get timeToday => 'Today';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeDaysAgo(int days) {
    return '$days days ago';
  }
}
