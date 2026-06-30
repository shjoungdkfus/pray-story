# 나의 서신서 (PrayStory) — 프로젝트 전체 보고서

> 최초 작성: 2026-06-12 / 최종 업데이트: 2026-06-30  
> 새 세션에서 "지금까지 뭐했지" 확인 → **`CHANGELOG.md`를 먼저 읽을 것** (날짜별 상세 기록)

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 이름 | 나의 서신서 / PrayStory (패키지명 기준 영문) |
| 컨셉 | "하나님이 오늘 나를 통해 써 내려가시는 양장 성경책 감성 UI" |
| 목적 | 개인 기도 일기 기록 + 기도 커뮤니티 앱 |
| 플랫폼 | Android (Flutter) |
| 개발 상태 | 전 기능 구현 완료 / 플레이스토어 배포 준비 완료 |
| applicationId | `com.praystory.pray_story` |
| GitHub | `https://github.com/shjoungdkfus/pray-story` |

---

## 2. 기술 스택

### Flutter 패키지 (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.6.1            # 상태 관리
  supabase_flutter: ^2.9.0            # 백엔드 (DB + 인증)
  google_fonts: ^6.2.1                # GowunBatang 폰트
  intl: ^0.20.2                       # 날짜 포맷 / 한국어
  shared_preferences: ^2.3.3          # 로컬 설정 저장
  share_plus: ^10.1.4                 # 그룹 초대 링크 공유
  flutter_local_notifications: ^18.0.0 # 기도 알림
  timezone: ^0.9.4                    # 알림 스케줄링 타임존
  url_launcher: ^6.3.1               # 피드백 mailto 외부 앱 연결
  flutter_localizations              # 한국어 로케일 (Cupertino 피커용)
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_launcher_icons: ^0.14.3    # Android 앱 아이콘 일괄 생성
```

### 백엔드: Supabase

| 항목 | 값 |
|------|----|
| 프로젝트명 | Pray-story |
| URL | `https://ljtsytknzfcuahqtbmqe.supabase.co` |
| Anon Key | `sb_publishable_9GFmKPM7t9S5wXIwaUe9WQ_mpvU8LmC` |
| 이메일 인증 | OFF (개발 편의) |

---

## 3. 디자인 시스템

### 컬러 팔레트 (AppColors)

| 이름 | HEX | 용도 |
|------|-----|------|
| background | `#FEFCF8` | 앱 전체 배경 (미세한 크림) |
| card | `#F5EBD5` | 카드, 바텀시트 배경 |
| searchBar | `#EDE0C4` | 하단 검색바 영역 |
| bottomBar | `#EFE6D0` | 하단 탭바 배경 |
| textPrimary | `#150A02` | 본문 텍스트 (진한 에스프레소 브라운) |
| accent | `#8B1A0F` | 강조색 (깊은 레드) |
| textHint | `#7A6050` | 힌트/비활성 텍스트 |
| divider | `#C4B49A` | 구분선 |

### 폰트

- **GowunBatang** (Google Fonts) — 전체 앱 적용
- 탭 제목: 22px bold, letterSpacing 1 (서신서 날짜 헤더 제외 좌측 정렬)

### 앱 아이콘

- 버건디(`#60041B`) 배경 + 크림색 P+S 펜촉 모노그램
- 기본: `assets/icon/app_icon.png` (1024×1024)
- 적응형 아이콘 전경: `assets/icon/app_icon_foreground.png` (안전영역 82% 축소)
- `flutter_launcher_icons`로 mdpi~xxxhdpi 전 해상도 생성

---

## 4. 데이터베이스 스키마 (Supabase)

### `prayers`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | 자동 생성 |
| user_id | uuid FK → auth.users | 작성자 |
| title | text | 기도 제목 (빈 문자열 허용) |
| content | text | 기도 내용 |
| created_at | timestamptz | 작성 시각 / 과거 날짜는 정오(12:00:00) sentinel |
| updated_at | timestamptz nullable | 수정 시각 |
| answered_at | timestamptz nullable | 기도 응답 체크 시각 |

> **날짜 sentinel 규칙**: 오늘 기록 → 실제 현재 시각 UTC / 과거 날짜 기록 → 해당 날짜 `12:00:00.000` UTC 고정 (시간대 변환 시 날짜 바뀜 방지)

RLS: 본인 user_id만 SELECT / INSERT / UPDATE / DELETE

---

### `profiles`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK FK → auth.users | 유저 ID |
| name | text | 이름 |
| birthdate | date nullable | 생년월일 |
| gender | text nullable | '남' / '여' |
| deleted_at | timestamptz nullable | 소프트 삭제 시각 (회원탈퇴 시 기록) |

---

### `community_groups`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| name | text | 그룹 이름 |
| description | text nullable | 한 줄 설명 |
| icon | text nullable | 이모지 아이콘 (12종 중 선택) |
| invite_code | text unique | 8자리 초대 코드 |
| owner_id | uuid FK → auth.users | 방장 |
| max_members | int | 최대 멤버 수 (기본 5) |
| created_at | timestamptz | |

RLS: 누구나 SELECT / 로그인 사용자 INSERT(본인이 owner) / 방장만 UPDATE·DELETE

---

### `group_members`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| group_id | uuid FK → community_groups | |
| user_id | uuid FK → auth.users | |
| role | text | 'owner' / 'member' |
| joined_at | timestamptz | |

UNIQUE(group_id, user_id). RLS: 누구나 SELECT / 본인만 INSERT·DELETE

---

### `community_letters`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| author_id | uuid FK → auth.users | |
| group_id | uuid FK nullable | null이면 전체 공개 |
| recipient_name | text nullable | "소중한 이에게" 대상 이름 |
| content | text | 편지 내용 |
| visibility | text | 'private' / 'group' / 'community' |
| anonymous_name | text | 익명 닉네임 (자동 생성) |
| anonymous_emoji | text | 익명 이모지 (자동 생성) |
| created_at | timestamptz | |

RLS: community는 누구나 조회 / 본인 글은 항상 조회 / 그룹 멤버는 group 글 조회 / 본인만 INSERT·DELETE

---

### `group_notices` — 2026-06-29 추가

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| group_id | uuid FK → community_groups | |
| author_id | uuid FK → auth.users | 방장만 작성 가능 |
| content | text | 공지 내용 |
| created_at | timestamptz | |

RLS: 그룹 멤버 SELECT / 방장만 INSERT·DELETE

---

### `letter_prayers` — 2026-06-29 추가 (서신 중보 반응)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| letter_id | uuid FK → community_letters | |
| user_id | uuid FK → auth.users | 함께 기도한 사용자 |
| created_at | timestamptz | |

UNIQUE(letter_id, user_id). RLS: 그룹 멤버 SELECT / 본인만 INSERT·DELETE (토글)

---

### `feedback` — 2026-06-30 추가

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid PK | |
| user_id | uuid FK nullable → auth.users | |
| type | text | 피드백 유형 칩 선택값 |
| content | text | 피드백 내용 |
| created_at | timestamptz | |

> **SQL 파일**: `docs/community_tables.sql` (v1), `docs/community_v2.sql` (v2 그룹 공지·중보), `docs/feedback_table.sql` (피드백·탈퇴)  
> **Supabase에서 직접 실행 필요** — `docs/feedback_table.sql` 미실행 시 피드백·탈퇴 기능 미동작

---

## 5. 앱 구조 (파일 트리)

```
lib/
├── main.dart                                  # MainShell — 하단 탭바 4개 + 중앙 FAB
├── core/
│   ├── constants/app_colors.dart              # 전체 컬러 팔레트
│   └── supabase/supabase_config.dart          # URL, Anon Key
├── models/
│   ├── prayer_model.dart
│   ├── profile_model.dart
│   ├── community_models.dart                  # CommunityGroup, GroupMember, CommunityLetter,
│   │                                          #   GroupNotice, LetterPrayerInfo
│   └── prayer_alarm_model.dart                # PrayerAlarm, TomorrowPrayerAlarm
├── providers/
│   ├── auth_provider.dart
│   ├── prayer_provider.dart                   # 기도 데이터·검색·통계
│   ├── profile_provider.dart
│   ├── font_size_provider.dart                # SharedPreferences (key: prayer_font_size)
│   ├── nav_provider.dart                      # shellTabProvider, previousTabProvider
│   ├── community_provider.dart                # 그룹·편지·공지·중보 Provider + CRUD
│   ├── notification_provider.dart             # 매일 알람·1회성 알람 StateNotifier
│   └── settings_provider.dart                 # themeModeProvider, languageProvider
├── services/
│   └── notification_service.dart              # flutter_local_notifications 래퍼
├── screens/
│   ├── auth/auth_screen.dart                  # 로그인 / 회원가입
│   ├── home/
│   │   ├── home_screen.dart                   # 메인 성경책 뷰
│   │   └── history_search_overlay.dart        # 하단 검색바 + 슬라이드 결과
│   ├── record/
│   │   ├── record_screen.dart                 # 기도 기록 탭
│   │   └── widgets/
│   │       ├── prayer_calendar.dart            # 월간 달력
│   │       ├── stats_summary_row.dart          # 통계 카드
│   │       ├── month_titles_section.dart       # 기도 제목·응답 목록
│   │       └── recent_records_section.dart     # 지난 기록 리스트
│   ├── community/
│   │   ├── community_screen.dart              # 커뮤니티 홈 (카테고리 + 피드)
│   │   ├── group_detail_screen.dart           # 그룹 상세 (공지/서신/멤버 탭)
│   │   ├── notice_write_screen.dart           # 공지 작성
│   │   ├── create_group_screen.dart
│   │   ├── join_group_screen.dart
│   │   ├── invite_group_screen.dart
│   │   ├── group_info_screen.dart
│   │   ├── pray_for_someone_screen.dart       # 소중한 이에게 2단계 작성
│   │   └── community_letter_write_screen.dart
│   ├── settings/
│   │   ├── settings_screen.dart               # 설정 허브 (그룹형 목록)
│   │   ├── profile_edit_screen.dart           # 내 정보 수정
│   │   ├── app_settings_screen.dart           # 앱 설정 (알림·테마·언어)
│   │   ├── notification_settings_screen.dart  # 매일 기도 알람 관리
│   │   ├── feedback_screen.dart               # 피드백 보내기
│   │   ├── account_screen.dart                # 로그아웃 / 회원탈퇴
│   │   └── widgets/settings_kit.dart          # 재사용 위젯 모음
│   └── write/prayer_write_screen.dart         # 기도 작성 / 수정
└── widgets/
    ├── font_size_picker_sheet.dart
    └── notification_picker_sheet.dart
```

---

## 6. 화면별 기능 명세

### 6-1. 인증 (auth_screen.dart)

- 로그인 / 회원가입 토글
- 회원가입: 이름·생년월일(Cupertino 피커)·성별 입력, 비밀번호 최소 길이 검증·한국어 에러 메시지
- Supabase Auth + profiles 테이블 동시 생성
- 버튼 텍스트: "성경책 열기"(로그인) / "서신서 시작하기"(회원가입)

---

### 6-2. 메인 화면 (home_screen.dart)

- **날짜 네비게이션 바**: 좌/우 화살표로 하루씩 이동, 날짜 탭 → Cupertino 날짜 피커
- **PageView**: 날짜별 페이지 스와이프 (오늘 이후 이동 불가)
- **스와이프 애니메이션**: Opacity(0.65→1.0) + Scale(0.96→1.0)
- **페이지 탭 동작**: 빈 페이지 탭 → 쓰기 / 글 있을 때 탭 → 수정 / 빈 공간 탭 → 새 글 쓰기
- **안내문**: 빈 페이지일 때 수직 중앙 배치
- **_BookContainer / _BookPage / _PrayerEntry**: 성경책 컨테이너 + 날짜별 기도 목록 + 항목별 밑줄(CustomPainter + TextPainter.computeLineMetrics)
- **글자크기 FAB**: 우하단, format_size 아이콘 → FontSizePickerSheet
- **_PrewarmWidget**: 현재 날짜 ±2일 데이터 prefetch

---

### 6-3. 기도 작성/수정 (prayer_write_screen.dart)

- **모드**: 새 기도 작성(`targetDate`) / 기존 기도 수정(`prayer`)
- **배경**: CustomPainter 원고지 줄 (_NoteLinesPainter)
- **저장 조건**: content 비어있으면 불가 / 수정 모드 시 변경사항 있을 때만 가능
- **날짜 처리**: 오늘 → 현재 시각 UTC / 과거 → 정오 sentinel UTC
- **내일 기도 알림**: TomorrowPrayerAlarm — 특정 날짜·시간에 해당 기도 재알림 설정 가능

---

### 6-4. 검색 오버레이 (history_search_overlay.dart)

- 하단 검색바 항상 표시, 입력 시 SizeTransition으로 결과창 슬라이드업
- Supabase `ilike`로 title + content 동시 검색, 최대 20건
- 결과 탭 → 해당 날짜 페이지로 이동

---

### 6-5. 기도 기록 탭 (record_screen.dart)

- **달력**: 월간 PageView 슬라이드, 기도 작성일 accent 원 표시 (PrayerCalendar)
- **통계 카드 2개**: "이번 달 기록 N일", "연속 기록 N일" (StatsSummaryRow)
- **기도 제목·응답 목록** (MonthTitlesSection): 응답 체크 토글, Supabase `answered_at` 업데이트
- **지난 기록 리스트** (RecentRecordsSection): 하단 스크롤 리스트
- 달력/제목 탭 → 서신서 탭으로 이동 + 해당 날짜 선택 (뒤로가기 시 기도기록 복귀)

---

### 6-6. 커뮤니티 탭 (community_screen.dart)

- 상단 타이틀 "기도 서신"
- **카테고리 가로 스크롤**: 모두의 서신 / 소중한 이에게 / 그룹 만들기(+) / 가입한 그룹들
- **모두의 서신 피드**: 전체 공개 편지, 익명 닉네임+이모지+날짜
- **소중한 이에게** (pray_for_someone_screen.dart): 대상 이름 입력 → 편지 작성(공개범위 선택)
- **그룹 만들기** (create_group_screen.dart) / **참여** (join_group_screen.dart)
- **그룹 선택** → GroupDetailScreen으로 Navigator.push

---

### 6-7. 그룹 상세 (group_detail_screen.dart) — 2026-06-29 개편

기존 커뮤니티 홈 내 인라인 뷰에서 별도 풀페이지로 분리.

- **헤더**: 이모지 아이콘 + 모임명 + 한 줄 설명 + ≡ 메뉴 버튼
- **세그먼트 탭 3개**:
  - **공지**: 금색 카드, 방장만 등록/삭제 → NoticeWriteScreen
  - **서신**: 편지 피드, 카드마다 "함께 기도" 중보 반응 (카운트 + 아바타 스택)
  - **멤버**: 방장 배지, 방장의 멤버 내보내기
- **우하단 FAB**: 알약형 "추가하기" → 바텀시트(편지 쓰기/공지 등록/멤버 초대)
- **≡ 메뉴**: 모임 이름·설명·이모지 아이콘(12종) 변경, 나가기(방장은 삭제)

---

### 6-8. 알림/기도 알람

- `notification_service.dart`: flutter_local_notifications + timezone 초기화, 예약/취소
- `PrayerAlarmsNotifier`: 매일 반복 알람 (기본 06:00, SharedPreferences 영속화)
- `TomorrowAlarmsNotifier`: 특정 기도글에 대한 1회성 미래 알림 (여러 날짜 동시 등록 가능)
- `notification_picker_sheet.dart`: 알림 시간 선택 바텀시트 (home_screen, prayer_write_screen에서 사용)

---

### 6-9. 설정 탭 (settings_screen.dart → 그룹형 허브) — 2026-06-30 전면 개편

설정 허브 화면에서 각 항목 탭 시 Navigator.push로 상세 페이지 이동.

| 메뉴 | 화면 | 기능 |
|------|------|------|
| 내 정보 | ProfileEditScreen | 이름·생년월일·성별 수정, profiles upsert |
| 앱 설정 | AppSettingsScreen | 알림·테마·언어 진입점 |
| → 알림 설정 | NotificationSettingsScreen | 매일 기도 알람 시간 추가·토글·삭제 (showTimePicker) |
| → 테마 | 바텀시트 | AppThemeMode (system/light/dark), SharedPreferences 저장만 — 실제 전환 미구현 |
| → 언어 | 바텀시트 | AppLanguage (ko/en), SharedPreferences 저장만 — 실제 전환 미구현 |
| 피드백 | FeedbackScreen | 유형 칩 + 내용 입력, Supabase `feedback` insert + url_launcher mailto 병행 |
| 계정 | AccountScreen | 로그아웃 / 회원탈퇴 (소프트 삭제: `profiles.deleted_at` + signOut) |

**재사용 위젯** (`settings_kit.dart`): SettingsDetailScaffold, SettingsGroup, SettingsTile, SettingsProfileHeader, SettingsRadioTile

---

### 6-10. 글자크기 피커 (font_size_picker_sheet.dart)

작게(11.0) / 보통(15.0) / 크게(25.0), '가' 미리보기, SharedPreferences 저장 (key: `prayer_font_size`)

---

## 7. 상태 관리 (Riverpod)

```
# 인증
supabaseProvider             → Supabase.instance.client
authStateProvider            → Stream<AuthState>
currentUserProvider          → User?

# 기도
selectedDateProvider         → StateProvider<DateTime>
prayersForDateProvider(date) → FutureProvider.family
searchQueryProvider          → StateProvider<String>
searchResultsProvider        → FutureProvider
statsViewModeProvider        → StateProvider<StatsViewMode>   # month / week
focusedMonthProvider         → StateProvider<DateTime>
monthPrayersProvider(month)  → FutureProvider.family
prayerStatsProvider          → FutureProvider<PrayerStats>    # writtenDays, streakCount, answeredCount, totalCount
answeredTitlesProvider       → FutureProvider

# 프로필·설정
profileProvider              → FutureProvider<ProfileModel?>
fontSizeProvider             → StateNotifierProvider<double>
themeModeProvider            → StateNotifierProvider<AppThemeMode>  # system / light / dark
languageProvider             → StateNotifierProvider<AppLanguage>   # ko / en

# 네비게이션
shellTabProvider             → StateProvider<int>    # 탭 인덱스
previousTabProvider          → StateProvider<int?>   # 뒤로가기 복귀용

# 커뮤니티
selectedCategoryProvider     → StateProvider<String>
myGroupsProvider             → FutureProvider.autoDispose<List<CommunityGroup>>
groupMembersProvider(gid)    → FutureProvider.autoDispose.family
communityLettersProvider     → FutureProvider.autoDispose
groupLettersProvider(gid)    → FutureProvider.autoDispose.family
groupNoticesProvider(gid)    → FutureProvider.autoDispose.family
letterPrayerProvider(lid)    → FutureProvider.autoDispose.family
# CRUD 함수: createGroup, joinGroupByCode, postCommunityLetter, leaveGroup,
#             deleteGroup, updateGroupName, updateGroupInfo, postNotice, deleteNotice,
#             toggleLetterPrayer, kickMember

# 알림
prayerAlarmsProvider         → StateNotifierProvider<List<PrayerAlarm>>         # 매일 알람
tomorrowAlarmsProvider       → StateNotifierProvider<List<TomorrowPrayerAlarm>> # 1회성 알람
```

---

## 8. 하단 네비게이션 구조 (main.dart)

```
MainShell (탭 인덱스: 0=서신서, 1=기도기록, 2=커뮤니티, 3=설정)
├── [탭 0] HomeScreen
├── [탭 1] RecordScreen
├── [중앙 FAB] + 버튼 (accent 원형) → PrayerWriteScreen 바텀시트
├── [탭 2] CommunityScreen
└── [탭 3] SettingsScreen
```

- 탭 전환: Stack + AnimatedOpacity(200ms) + IgnorePointer (화면 keep-alive)
- 하단 탭: 아이콘만 표시, 텍스트 라벨 없음
- PopScope: 기도기록/커뮤니티/설정 탭에서 뒤로가기 → 서신서(탭0)로 복귀

---

## 9. 개발 환경 및 배포 설정

| 항목 | 내용 |
|------|------|
| 실기기 | 갤럭시 S23 (USB 디버깅) |
| ADB 경로 | `C:\Users\shjou\AppData\Local\Android\Sdk\platform-tools\adb.exe` |
| 실행 명령 | `flutter run` |
| 릴리즈 빌드 | `flutter build appbundle --release` (AAB 43.5MB) / `flutter build apk --release` (APK 55.0MB) |
| 키스토어 | `android/upload-keystore.jks` (alias `upload`, RSA 2048, ~2053년) — git 제외 |
| 키스토어 설정 | `android/key.properties` — git 제외, `android/key.properties.template` 참고 |
| ProGuard | `android/app/proguard-rules.pro` — release 빌드에 minify + 리소스 축소 활성화 |
| Dart SDK | ^3.11.5 |

**릴리즈 빌드 시 주의**: `build.gradle.kts`의 release 블록은 `key.properties` 유무로 서명/디버그 자동 폴백. `key.properties` 없으면 디버그 키로 서명됨.

---

## 10. 진행 경과 타임라인

| 날짜 | 내용 |
|------|------|
| ~06-12 | 서신서(홈)·기도작성·검색·설정·인증 핵심 기능 구현, 실기기 테스트 완료 |
| 06-15 | 기도기록 탭(달력·통계·응답체크), 커뮤니티 DB 테이블 설계·구현 |
| 06-17 | 커뮤니티 기능 전체 구현(그룹/편지/초대), 기도 알림 추가, 색상 가시성 강화, 탭 UI 정리 |
| 06-20 | GitHub 저장소 연동 |
| 06-23 | 릴리즈 키스토어 생성, ProGuard 설정, 앱 아이콘 적용, 릴리즈 APK 갤럭시 S23 검증, 배포 준비 검토 |
| 06-24 | 스플래시 스크린 시안 2종 추가, Gradle 래퍼 파일 git 추적 |
| 06-29 | 서신함(아카이브) 탭 제거·대규모 UI 리팩토링, 그룹 상세 화면 전면 개편(공지/서신/멤버 탭, 중보 반응, `group_notices`·`letter_prayers` 테이블 추가) |
| 06-30 | 설정 탭 전면 재디자인(6개 신규 파일, url_launcher 추가), ProGuard JNI·app_links 보완, 홈 UX 수정, 탭 헤더 정렬 통일 |

---

## 11. 코드 파일 경로 일람

| 역할 | 경로 |
|------|------|
| 앱 진입점 | `lib/main.dart` |
| 컬러 | `lib/core/constants/app_colors.dart` |
| Supabase 설정 | `lib/core/supabase/supabase_config.dart` |
| 기도 모델 | `lib/models/prayer_model.dart` |
| 프로필 모델 | `lib/models/profile_model.dart` |
| 커뮤니티 모델 | `lib/models/community_models.dart` |
| 알람 모델 | `lib/models/prayer_alarm_model.dart` |
| 인증 Provider | `lib/providers/auth_provider.dart` |
| 기도 Provider | `lib/providers/prayer_provider.dart` |
| 프로필 Provider | `lib/providers/profile_provider.dart` |
| 글자크기 Provider | `lib/providers/font_size_provider.dart` |
| 탭 상태 Provider | `lib/providers/nav_provider.dart` |
| 커뮤니티 Provider | `lib/providers/community_provider.dart` |
| 알림 Provider | `lib/providers/notification_provider.dart` |
| 설정 Provider | `lib/providers/settings_provider.dart` |
| 알림 서비스 | `lib/services/notification_service.dart` |
| 로그인 화면 | `lib/screens/auth/auth_screen.dart` |
| 메인 화면 | `lib/screens/home/home_screen.dart` |
| 검색 오버레이 | `lib/screens/home/history_search_overlay.dart` |
| 기도기록 화면 | `lib/screens/record/record_screen.dart` |
| 커뮤니티 홈 | `lib/screens/community/community_screen.dart` |
| 그룹 상세 | `lib/screens/community/group_detail_screen.dart` |
| 공지 작성 | `lib/screens/community/notice_write_screen.dart` |
| 그룹 만들기 | `lib/screens/community/create_group_screen.dart` |
| 그룹 참여 | `lib/screens/community/join_group_screen.dart` |
| 초대 코드 | `lib/screens/community/invite_group_screen.dart` |
| 그룹 정보 | `lib/screens/community/group_info_screen.dart` |
| 소중한 이에게 | `lib/screens/community/pray_for_someone_screen.dart` |
| 편지 작성 | `lib/screens/community/community_letter_write_screen.dart` |
| 설정 허브 | `lib/screens/settings/settings_screen.dart` |
| 내 정보 수정 | `lib/screens/settings/profile_edit_screen.dart` |
| 앱 설정 | `lib/screens/settings/app_settings_screen.dart` |
| 알림 설정 | `lib/screens/settings/notification_settings_screen.dart` |
| 피드백 | `lib/screens/settings/feedback_screen.dart` |
| 계정 | `lib/screens/settings/account_screen.dart` |
| 설정 위젯 모음 | `lib/screens/settings/widgets/settings_kit.dart` |
| 기도 작성 화면 | `lib/screens/write/prayer_write_screen.dart` |
| 글자크기 피커 | `lib/widgets/font_size_picker_sheet.dart` |
| 알림 시간 피커 | `lib/widgets/notification_picker_sheet.dart` |
| 커뮤니티 DB v1 | `docs/community_tables.sql` |
| 커뮤니티 DB v2 | `docs/community_v2.sql` |
| 피드백·탈퇴 DB | `docs/feedback_table.sql` |
