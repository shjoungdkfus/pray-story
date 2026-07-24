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

  @override
  String get recordDeleted => '기록이 삭제되었습니다.';

  @override
  String get undoDelete => '되돌리기';

  @override
  String get errRestoreFailed => '복원 중 문제가 발생했습니다.';

  @override
  String get draftRestored => '작성 중이던 내용을 불러왔어요.';

  @override
  String get offlineCachedNotice => '오프라인 상태예요 · 온라인 연결을 권장해요';

  @override
  String get errDeleteFailed => '삭제 중 문제가 발생했습니다.';

  @override
  String get errSaveFailed => '저장 중 문제가 발생했습니다. 다시 시도해주세요.';

  @override
  String get timeJustNow => '방금 전';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String get homeToToday => '오늘로';

  @override
  String get homeDefaultName => '나';

  @override
  String homeStoryOf(String name) {
    return '$name의 이야기';
  }

  @override
  String get homeEmptyToday => '오늘 하루, 당신의 삶에\n행하신 하나님의 이야기를\n기록해 보세요.';

  @override
  String get homeEmptyOther => '이 날의 이야기를\n기록해 보세요.';

  @override
  String get searchHint => '날짜, 기도 제목, 키워드로 기록을 찾아보세요';

  @override
  String get searchUntitled => '(제목 없음)';

  @override
  String get writeDeleteTitle => '기록 삭제';

  @override
  String get writeDeleteMessage => '이 기도 기록을 삭제하시겠습니까?';

  @override
  String get buttonCancel => '취소';

  @override
  String get buttonDelete => '삭제';

  @override
  String get writeUpdated => '수정되었습니다.';

  @override
  String get writeSavedToday => '오늘의 한 페이지가 기록되었습니다.';

  @override
  String get writeSaved => '기도 기록이 저장되었습니다.';

  @override
  String get writeTitleEdit => '기록 수정';

  @override
  String get writeTitleToday => '오늘의 기록';

  @override
  String get writeTitleOther => '기도 기록';

  @override
  String get writeSubmitEdit => '수정';

  @override
  String get writeSubmitToday => '기록하기';

  @override
  String get writeSubmitOther => '저장하기';

  @override
  String get writeHintTitle => '기도 제목';

  @override
  String get writeHintContent => '하나님께 올릴 이야기를 작성해주세요.';

  @override
  String get recordTitle => '나의 기도 기록';

  @override
  String get statUnitDays => '일';

  @override
  String get statUnitCount => '개';

  @override
  String get statThisMonth => '이번 달 기록';

  @override
  String get statAnswered => '응답 기록';

  @override
  String get recordPrayerTitles => '기도 제목';

  @override
  String get recordRecent => '지난 기록';

  @override
  String get recordUntitled => '무제';

  @override
  String recordLoadError(Object error) {
    return '오류: $error';
  }

  @override
  String recordWeekLabel(int week, String month) {
    return '$month $week주차';
  }

  @override
  String commonError(Object error) {
    return '오류: $error';
  }

  @override
  String get communityTitle => '기도 모임';

  @override
  String get communitySubtitle => '가족·친구와 함께 기도를 나눠요';

  @override
  String get communityCreateGroup => '모임 만들기';

  @override
  String get communityInviteCode => '초대 코드';

  @override
  String get communityMyGroups => '내 모임';

  @override
  String get communityGroupDefaultDesc => '함께 기도하는 모임';

  @override
  String get communityEmptyTitle => '아직 모임이 없어요';

  @override
  String get communityEmptySubtitle => '가족·친구와 함께 기도할\n첫 모임을 만들어보세요';

  @override
  String get createGroupTitle => '그룹 만들기';

  @override
  String get createGroupHeading => '함께 기도할\n그룹을 만들어요';

  @override
  String get createGroupDesc => '초대 코드로 가족, 친구와 함께\n서로의 기도 편지를 나눠보세요';

  @override
  String get createGroupNameLabel => '그룹 이름';

  @override
  String get createGroupNameHint => '예) 가족 기도방, 셀 그룹, ...';

  @override
  String get createGroupJoinLink => '초대 코드로 그룹 참가하기';

  @override
  String createGroupSuccess(String name) {
    return '$name - 그룹을 만들었습니다';
  }

  @override
  String get joinGroupTitle => '그룹 참여';

  @override
  String get joinGroupHeading => '초대 코드 입력';

  @override
  String get joinGroupDesc => '그룹 방장에게 받은 초대 코드를 입력하세요';

  @override
  String get joinGroupButton => '참여하기';

  @override
  String joinGroupSuccess(String name) {
    return '$name 그룹에 참여했습니다';
  }

  @override
  String get inviteHeading => '나의 그룹에 초대하기';

  @override
  String get inviteDesc => '친구와 가족을 초대하고 함께\n기도 편지를 나눠보세요';

  @override
  String get inviteCodeCopied => '초대 코드가 복사되었습니다';

  @override
  String get inviteShareButton => '초대 링크 공유하기';

  @override
  String inviteShareMessage(String name, String code) {
    return 'PrayStory 앱에서 함께 기도해요!\n그룹: $name\n초대 코드: $code';
  }

  @override
  String get groupInfoTitle => '그룹 정보';

  @override
  String get groupLeave => '그룹 나가기';

  @override
  String get groupLeaveConfirm => '정말 이 그룹을 나가시겠습니까?';

  @override
  String get groupLeaveAction => '나가기';

  @override
  String get groupDelete => '그룹 삭제';

  @override
  String get groupDeleteConfirm => '이 그룹과 모든 편지가 삭제됩니다.\n정말 삭제하시겠습니까?';

  @override
  String groupMemberCount(int count) {
    return '멤버 $count명';
  }

  @override
  String groupMemberCountMax(int count, int max) {
    return '$count / $max 멤버';
  }

  @override
  String get groupInvite => '초대하기';

  @override
  String groupCreatedOn(String date) {
    return '$date에 만들어짐';
  }

  @override
  String get groupRename => '그룹 이름 변경';

  @override
  String get groupRenameHint => '새 그룹 이름';

  @override
  String get buttonChange => '변경';

  @override
  String get roleOwner => '방장';

  @override
  String get noticeWriteTitle => '공지 등록';

  @override
  String get buttonPost => '등록';

  @override
  String get noticeBadge => '공지';

  @override
  String noticeDeliveredTo(String name) {
    return '$name 멤버에게 전달됩니다';
  }

  @override
  String get noticeHint => '함께 나눌 공지 내용을 적어주세요';

  @override
  String get noticePosted => '공지가 등록되었습니다';

  @override
  String get letterSent => '기도 편지가 전달되었습니다';

  @override
  String get visibilityPrivate => '나만보기';

  @override
  String get visibilityGroup => '그룹';

  @override
  String get visibilityCommunity => '커뮤니티';

  @override
  String letterForRecipient(String name) {
    return '$name 위한 편지';
  }

  @override
  String get prayForHeading => '소중한 이에게\n기도 편지를 전해요';

  @override
  String get prayForDesc => '이름을 입력하면 그 사람을 위한\n기도 편지를 쓸 수 있어요';

  @override
  String get prayForRecipientLabel => '받는 이';

  @override
  String get prayForRecipientHint => '예) 엄마, 친구 민준이, ...';

  @override
  String get prayForButton => '편지 쓰러 가기';

  @override
  String groupHeaderFriends(int count) {
    return '함께 기도하는 $count명의 벗';
  }

  @override
  String get groupAdd => '추가하기';

  @override
  String get tabNotice => '공지';

  @override
  String get tabLetters => '서신';

  @override
  String get tabMembers => '멤버';

  @override
  String get groupWriteLetter => '편지 쓰기';

  @override
  String get groupPostNotice => '공지 등록하기';

  @override
  String get groupInviteMember => '멤버 초대하기';

  @override
  String get groupEditDesc => '모임 설명 변경';

  @override
  String get groupDescHint => '모임을 한 줄로 소개해 주세요';

  @override
  String get groupChangeIcon => '아이콘 변경';

  @override
  String get groupManageMembers => '멤버 권한 관리';

  @override
  String get groupIconPick => '아이콘 선택';

  @override
  String get buttonSave => '저장';

  @override
  String get groupLeaveOwnerConfirm => '방장이 나가면 모임과 모든 글이 삭제됩니다.\n정말 나가시겠어요?';

  @override
  String get noticeEmptyTitle => '등록된 공지가 없어요';

  @override
  String get noticeEmptyOwner => '추가하기로 첫 공지를 남겨보세요';

  @override
  String get noticeEmptyMember => '방장의 공지를 기다려 주세요';

  @override
  String get noticeLoadErrorTitle => '공지를 불러오지 못했어요';

  @override
  String get noticeLoadErrorSubtitle => 'community_v2.sql 을 실행했는지 확인해 주세요';

  @override
  String get letterEmptyTitle => '아직 나눈 서신이 없어요';

  @override
  String get letterEmptySubtitle => '추가하기로 첫 기도 편지를 남겨보세요';

  @override
  String letterToRecipient(String name) {
    return '$name에게';
  }

  @override
  String prayTogetherCount(int count) {
    return '🙏 함께 기도한 $count명';
  }

  @override
  String get prayTogetherDesc => '이 기도에 함께해 주신 분들이에요';

  @override
  String get anonymous => '익명';

  @override
  String get prayedTogether => '함께 기도함';

  @override
  String get prayTogether => '함께 기도';

  @override
  String get anonymousFriend => '익명의 벗';

  @override
  String get memberKickTitle => '멤버 내보내기';

  @override
  String memberKickConfirm(String name) {
    return '$name님을 모임에서 내보낼까요?';
  }

  @override
  String get memberDefault => '이 멤버';

  @override
  String get memberKickAction => '내보내기';

  @override
  String get timeToday => '오늘';

  @override
  String get timeYesterday => '어제';

  @override
  String timeDaysAgo(int days) {
    return '$days일 전';
  }

  @override
  String get timeTomorrow => '내일';

  @override
  String get notifSettingsInfo => '설정한 시간마다 매일 기도 알림을 보내드려요.';

  @override
  String get notifEmptyTitle => '등록된 알림이 없어요';

  @override
  String get notifDailyGroup => '매일 기도 알림';

  @override
  String get notifAddButton => '알림 추가';

  @override
  String get feedbackContentRequired => '내용을 입력해 주세요.';

  @override
  String get feedbackDesc =>
      '앱을 사용하며 느낀 점이나 개선 아이디어를 들려주세요. 보내주신 의견은 관리자에게 직접 전달돼요.';

  @override
  String get feedbackTypeLabel => '유형';

  @override
  String get feedbackContentLabel => '내용';

  @override
  String get feedbackContentHint => '내용을 자유롭게 적어 주세요.';

  @override
  String get feedbackSendButton => '보내기';

  @override
  String get feedbackSentSuccess => '소중한 의견 감사합니다. 잘 전달되었어요.';

  @override
  String get feedbackSendFailed => '전송에 실패했어요. 메일로 보내기를 이용해 주세요.';

  @override
  String get feedbackEmailButton => '메일 앱으로 보내기';

  @override
  String get feedbackEmailFailed => '메일 앱을 열 수 없어요.';

  @override
  String get feedbackSubjectPrefix => '[PrayStory 피드백]';

  @override
  String get feedbackEmailFrom => '보낸사람';

  @override
  String get feedbackEmailVersion => '앱 버전';

  @override
  String get feedbackCatBug => '버그 신고';

  @override
  String get feedbackCatFeature => '기능 제안';

  @override
  String get feedbackCatInquiry => '문의';

  @override
  String get feedbackCatOther => '기타';

  @override
  String get accountLogout => '로그아웃';

  @override
  String get accountLogoutConfirm => '정말 로그아웃 하시겠어요?';

  @override
  String get accountWithdraw => '회원 탈퇴';

  @override
  String get accountWithdrawConfirm =>
      '탈퇴하면 계정이 비활성화되고 더 이상 로그인할 수 없어요.\n정말 탈퇴하시겠어요?';

  @override
  String get accountWithdrawButton => '탈퇴하기';

  @override
  String get accountWithdrawFailed => '탈퇴 처리 중 문제가 발생했어요. 다시 시도해 주세요.';

  @override
  String get accountWithdrawNote =>
      '탈퇴 시 계정은 비활성화 처리돼요. 작성하신 기도 기록의 완전 삭제를 원하시면 피드백으로 문의해 주세요.';

  @override
  String get letterOpeningHint => '하나님 아버지,';

  @override
  String get letterDeleteTitle => '편지 삭제';

  @override
  String get letterDeleteConfirm => '이 편지를 삭제하시겠어요?\n삭제하면 되돌릴 수 없어요.';

  @override
  String get letterDeleteButton => '삭제하기';

  @override
  String get profileEditHeading => '원하시는 정보로\n프로필을 수정해보세요';

  @override
  String get profileEditSaved => '저장되었습니다.';

  @override
  String get profileEditSaveFailed => '저장 중 문제가 발생했습니다. 다시 시도해주세요.';

  @override
  String get profileEditButton => '수정하기';

  @override
  String get settingsNoNamePlaceholder => '이름을 설정해 주세요';

  @override
  String get fontSizeTitle => '글자 크기';

  @override
  String get fontSizeSmall => '작게';

  @override
  String get fontSizeMedium => '보통';

  @override
  String get fontSizeLarge => '크게';

  @override
  String get fontSizeSample => '가';

  @override
  String get notifPickerTitle => '알림 시간';

  @override
  String get buttonDone => '완료';

  @override
  String get dateSelectTitle => '날짜 선택';

  @override
  String get dateSelectHint => '탭으로 하나씩, 드래그로 여러 날짜를 한번에 선택할 수 있어요.';

  @override
  String get dateNotSelected => '날짜를 선택해주세요';

  @override
  String dateAndOthers(String first, int count, int total) {
    return '$first 외 $count일 · 총 $total일 선택';
  }

  @override
  String get periodAm => '오전';

  @override
  String get periodPm => '오후';

  @override
  String get notifChannelPrayerName => '기도 알림';

  @override
  String get notifChannelPrayerDesc => '기도 제목 알림';

  @override
  String get notifChannelTomorrowName => '내일을 위한 기도';

  @override
  String get notifChannelTomorrowDesc => '내일을 위해 작성한 기도 제목 알림';

  @override
  String get notifDailyTitle => '기도 시간이에요';

  @override
  String get notifDailyBody => '오늘을 위한 기도 제목을 확인해 보세요.';
}
