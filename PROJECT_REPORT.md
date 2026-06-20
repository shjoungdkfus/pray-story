# 나의 서신서 (Pray_Story) — 프로젝트 전체 보고서

> 작성일: 2026-06-12 / 최종 업데이트: 2026-06-20
> 작성자: Claude (AI 코드 어시스턴트)

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 이름 | 나의 서신서 (Pray_Story) |
| 컨셉 | "하나님이 오늘 나를 통해 써 내려가시는 양장 성경책 감성 UI" |
| 목적 | 개인 기도 일기 기록 + 기도 커뮤니티 앱 |
| 플랫폼 | Android (Flutter) |
| 개발 상태 | 핵심 기능(서신서/기도기록/커뮤니티/알림/설정) 전체 구현 완료 / 실기기 테스트 완료 |

---

## 2. 기술 스택

### Flutter 패키지 (pubspec.yaml)
```yaml
dependencies:
  flutter_riverpod: ^2.6.1            # 상태 관리
  supabase_flutter: ^2.9.0            # 백엔드 (DB + 인증)
  google_fonts: ^6.2.1                # GowunBatang 폰트
  intl: ^0.20.2                       # 날짜 포맷 / 한국어
  shared_preferences: ^2.3.3          # 로컬 설정 저장 (글자크기, 알람)
  share_plus: ^10.1.4                 # 그룹 초대 링크 공유
  flutter_local_notifications: ^18.0.0 # 기도 알림
  timezone: ^0.9.4                    # 알림 스케줄링 타임존
  flutter_localizations                # 한국어 로케일 (Cupertino 피커용)
  cupertino_icons: ^1.0.8
```

### 백엔드: Supabase
- **프로젝트명:** Pray-story
- **URL:** `https://ljtsytknzfcuahqtbmqe.supabase.co`
- **Anon Key:** `sb_publishable_9GFmKPM7t9S5wXIwaUe9WQ_mpvU8LmC`
- **이메일 인증:** OFF (개발 편의)

### 형상관리
- GitHub: `https://github.com/shjoungdkfus/pray-story`

---

## 3. 디자인 시스템

### 컬러 팔레트 (AppColors) — 2026-06-17 가시성 강화 업데이트
| 이름 | HEX | 용도 |
|------|-----|------|
| background | `#FEFCF8` | 앱 전체 배경 (거의 흰색, 미세한 크림) |
| card | `#F5EBD5` | 카드, 바텀시트 배경 (배경과 대비 강화) |
| searchBar | `#EDE0C4` | 하단 검색바 영역 |
| bottomBar | `#EFE6D0` | 하단 탭바 배경 |
| textPrimary | `#150A02` | 본문 텍스트 (진한 에스프레소 브라운) |
| accent | `#8B1A0F` | 강조색 (깊은 레드, 가시성 강화) |
| textHint | `#7A6050` | 힌트/비활성 텍스트 (중간 브라운, 계층 구분) |
| divider | `#C4B49A` | 구분선 (선명하게) |

### 폰트
- **GowunBatang** (Google Fonts) — 한국 붓글씨 감성, 전체 앱에 적용
- 커뮤니티/기도기록/설정 탭의 제목 글씨체·크기 통일 (22px bold, letterSpacing 1)

---

## 4. 데이터베이스 스키마 (Supabase)

### 테이블: `prayers`
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | 자동 생성 |
| user_id | uuid (FK → auth.users) | 작성자 |
| title | text | 기도 제목 (빈 문자열 허용) |
| content | text | 기도 내용 |
| created_at | timestamptz | 작성 시각 / 과거 날짜 기록 시 정오(12:00:00) sentinel |
| updated_at | timestamptz (nullable) | 수정 시각 |
| answered_at | timestamptz (nullable) | 기도 응답 체크 시각 (기도기록 탭) |

**RLS 정책:** 본인 user_id만 SELECT / INSERT / UPDATE / DELETE 가능

#### 과거 날짜 기록 규칙 (sentinel)
- 오늘 기록 → `created_at` = 실제 현재 시각
- 과거 날짜 기록 → `created_at` = 해당 날짜의 `12:00:00.000` (정오 고정)
- 이유: 시간대(UTC ↔ 로컬) 변환 시 날짜가 바뀌는 문제 방지

### 테이블: `profiles`
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK, FK → auth.users) | 유저 ID와 동일 |
| name | text | 이름 |
| birthdate | date (nullable) | 생년월일 |
| gender | text (nullable) | 성별 ('남' / '여') |

### 테이블: `community_groups` (2026-06-15 추가)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | 그룹 ID |
| name | text | 그룹 이름 |
| invite_code | text (unique) | 8자리 초대 코드 |
| owner_id | uuid (FK → auth.users) | 방장 |
| max_members | int | 최대 멤버 수 (기본 5) |
| created_at | timestamptz | 생성일 |

RLS: 누구나 SELECT(초대코드 조회용) / 로그인 사용자 INSERT(본인이 owner) / 방장만 UPDATE·DELETE

### 테이블: `group_members` (2026-06-15 추가)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | |
| group_id | uuid (FK → community_groups) | |
| user_id | uuid (FK → auth.users) | |
| role | text | 'owner' / 'member' |
| joined_at | timestamptz | 가입일 |

RLS: 누구나 SELECT / 본인만 INSERT·DELETE(가입/탈퇴) / `UNIQUE(group_id, user_id)`

### 테이블: `community_letters` (2026-06-15 추가)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | |
| author_id | uuid (FK → auth.users) | 작성자 |
| group_id | uuid (FK, nullable) | 그룹 (null이면 커뮤니티 전체) |
| recipient_name | text (nullable) | "소중한 이에게" 대상 이름 |
| content | text | 편지 내용 |
| visibility | text | 'private' / 'group' / 'community' |
| anonymous_name | text | 익명 닉네임 (자동 생성, 예: gentle-lamb) |
| anonymous_emoji | text | 익명 이모지 (자동 생성) |
| created_at | timestamptz | 작성일 |

RLS: `visibility='community'`는 누구나 조회 / 본인 글은 항상 조회 / 그룹 멤버는 그룹 글 조회 / 본인만 INSERT·DELETE

전체 SQL: `docs/community_tables.sql` 참고. 기능 명세 전문은 `docs/community_spec.md` 참고.

---

## 5. 앱 구조 (파일 트리)

```
lib/
├── main.dart                          # 앱 진입점, MainShell (하단 탭바 4개)
├── core/
│   ├── constants/
│   │   └── app_colors.dart            # 전체 컬러 팔레트
│   └── supabase/
│       └── supabase_config.dart       # URL, Anon Key
├── models/
│   ├── prayer_model.dart              # 기도 데이터 모델
│   ├── profile_model.dart             # 유저 프로필 모델
│   ├── community_models.dart          # CommunityGroup, GroupMember, CommunityLetter
│   └── prayer_alarm_model.dart        # PrayerAlarm, TomorrowPrayerAlarm
├── providers/
│   ├── auth_provider.dart             # 인증 상태 Provider
│   ├── prayer_provider.dart           # 기도 데이터/검색/통계 Provider
│   ├── profile_provider.dart          # 프로필 Provider
│   ├── font_size_provider.dart        # 글자크기 Provider (SharedPreferences)
│   ├── nav_provider.dart              # 하단 탭 상태 (shellTabProvider 등)
│   ├── community_provider.dart        # 커뮤니티 그룹/편지 Provider + CRUD 함수
│   └── notification_provider.dart     # 기도 알람 Provider (StateNotifier)
├── services/
│   └── notification_service.dart      # flutter_local_notifications 래퍼
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart           # 로그인 / 회원가입
│   ├── home/
│   │   ├── home_screen.dart           # 메인 성경책 뷰
│   │   └── history_search_overlay.dart # 하단 검색바 + 슬라이드 결과
│   ├── record/
│   │   ├── record_screen.dart         # 기도 기록 탭 (월간/주간 토글)
│   │   └── widgets/
│   │       ├── prayer_calendar.dart      # 월간/주간 달력
│   │       ├── stats_summary_row.dart    # 통계 카드 2개
│   │       └── month_titles_section.dart # 기도 제목·응답 목록
│   ├── community/
│   │   ├── community_screen.dart            # 커뮤니티 홈 (카테고리 + 피드)
│   │   ├── create_group_screen.dart          # 그룹 만들기
│   │   ├── join_group_screen.dart            # 초대코드로 그룹 참여
│   │   ├── invite_group_screen.dart          # 초대 코드 표시 + 공유
│   │   ├── group_info_screen.dart            # 그룹 정보/멤버/나가기·삭제
│   │   ├── pray_for_someone_screen.dart      # "소중한 이에게" 2단계 작성
│   │   └── community_letter_write_screen.dart # 커뮤니티/그룹 편지 작성
│   ├── settings/
│   │   └── settings_screen.dart       # 프로필 정보 + 로그아웃
│   └── write/
│       └── prayer_write_screen.dart   # 기도 작성 / 수정
└── widgets/
    ├── font_size_picker_sheet.dart    # 글자크기 선택 바텀시트
    └── notification_picker_sheet.dart # 기도 알림 시간 선택 바텀시트
```

---

## 6. 화면별 기능 명세

### 6-1. 인증 화면 (auth_screen.dart)
- 로그인 / 회원가입 토글
- 회원가입 시 이름, 생년월일(Cupertino 피커), 성별 입력
- Supabase Auth + profiles 테이블 동시 생성
- 버튼 텍스트: "성경책 열기" (로그인) / "서신서 시작하기" (회원가입)

### 6-2. 메인 화면 (home_screen.dart)
- **날짜 네비게이션 바:** 좌/우 화살표로 하루씩 이동, 날짜 탭 → Cupertino 날짜 피커
- **PageView:** 날짜별 페이지 스와이프 (오늘 이후로는 이동 불가)
- **스와이프 애니메이션:** Opacity(0.65~1.0) + Scale(0.96~1.0)
- **_BookContainer / _BookPage / _PrayerEntry:** 성경책 모양 컨테이너 + 날짜별 기도 목록 + 항목별 밑줄(CustomPainter)
- **글자크기 FAB:** 우하단 (검색바 바로 위), format_size 아이콘
- **알림 설정:** notification_picker_sheet 연동 (매일 기도 알람)
- **_PrewarmWidget:** 현재 날짜 ±2일 데이터 prefetch

### 6-3. 기도 작성/수정 화면 (prayer_write_screen.dart)
- **모드:** 새 기도 작성(`targetDate`) / 기존 기도 수정(`prayer`)
- **배경:** CustomPainter로 원고지 줄 그리기 (_NoteLinesPainter)
- **저장 조건:** content 비어있으면 불가 / 수정 모드 시 변경사항 있을 때만 가능
- **날짜 처리:** 오늘 → 현재 시각 UTC / 과거 → 정오 sentinel UTC
- **내일 기도 알림:** 작성한 기도를 특정 날짜·시간에 다시 알려주는 TomorrowPrayerAlarm 설정 가능

### 6-4. 검색 오버레이 (history_search_overlay.dart)
- 하단 검색바 항상 표시, 입력 시 SizeTransition으로 결과창 슬라이드업
- Supabase `ilike` 쿼리로 title + content 동시 검색, 최대 20건
- 결과 탭 → 해당 날짜 페이지로 이동

### 6-5. 기도 기록 탭 (record_screen.dart)
- 상단 타이틀 "나의 기도 기록" (GowunBatang 22px bold, 다른 탭 제목과 통일)
- 월간/주간 토글 pill (AnimatedContainer)
- 통계 카드 2개: "이번 달 기록 N일", "연속 기록 N일" (StatsSummaryRow)
- 월간 달력: PageView 슬라이드, 기도 작성일 accent 원 표시 (PrayerCalendar)
- 주간 달력: 이번 주 월~일 7칸
- **기도 제목·응답 목록 (MonthTitlesSection):** 응답 체크 토글, 안내용 회색 보조 캡션("한눈에 보기") 제거 — 깔끔한 레이아웃으로 정리
- 달력/제목 탭 → 서신서 탭(홈)으로 이동 + 해당 날짜 선택 (뒤로가기 시 기도기록으로 복귀)

### 6-6. 커뮤니티 탭 (community_screen.dart) — 2026-06-15~17 추가
- 상단 타이틀 "기도 서신" (제목 스타일 다른 탭과 통일)
- **카테고리 가로 스크롤:** 모두의 서신 / 소중한 이에게 / 그룹 만들기(+) / 가입한 그룹들
- **모두의 서신(_CommunityFeed):** 전체 공개 편지 피드, 익명 닉네임+이모지+날짜
- **소중한 이에게(pray_for_someone_screen.dart):** 대상 이름 입력 → 편지 작성(공개범위 선택)
- **그룹 만들기(create_group_screen.dart) / 참여(join_group_screen.dart):** 그룹명 입력 또는 초대코드 입력
- **그룹 상세(_GroupDetailView):** 액션 칩 3개(편지쓰기/초대/그룹정보) + 그룹 피드
- **초대(invite_group_screen.dart):** 초대 코드 복사 + share_plus로 공유
- **그룹 정보(group_info_screen.dart):** 멤버 목록, 그룹명 수정(방장), 나가기/삭제
- **편지 작성(community_letter_write_screen.dart):** 공개범위(나만/그룹/커뮤니티) 선택, 익명 처리

### 6-7. 알림/기도 알람 — 2026-06-17 추가
- `notification_service.dart`: flutter_local_notifications + timezone 초기화, 일정 예약/취소
- `notification_provider.dart`:
  - `PrayerAlarmsNotifier` — 매일 반복 알람 (기본 06:00, SharedPreferences 영속화)
  - `TomorrowAlarmsNotifier` — 특정 기도글에 대한 1회성 미래 알림(여러 날짜 동시 등록 가능)
- `notification_picker_sheet.dart`: 알림 시간 선택 바텀시트 (home_screen, prayer_write_screen에서 사용)

### 6-8. 설정 화면 (settings_screen.dart)
- 이름, 생년월일, 성별, 이메일 표시 (profiles 테이블)
- 로그아웃 버튼
- 타이틀 스타일 다른 탭과 통일

### 6-9. 글자크기 피커 (font_size_picker_sheet.dart)
- 작게(11.0) / 보통(15.0) / 크게(25.0) 3단계, '가' 미리보기
- 선택 시 SharedPreferences 저장 (`prayer_font_size`)

---

## 7. 상태 관리 구조 (Riverpod)

```
supabaseProvider             → Supabase.instance.client
authStateProvider            → Stream<AuthState>
currentUserProvider          → User? (authState에서 추출)

selectedDateProvider         → StateProvider<DateTime> (선택된 날짜)
prayersForDateProvider(date) → FutureProvider.family (날짜별 기도 목록)
searchQueryProvider          → StateProvider<String>
searchResultsProvider        → FutureProvider (검색 결과)
statsViewModeProvider        → StateProvider<StatsViewMode> (month/week)
focusedMonthProvider         → StateProvider<DateTime> (달력 표시 월)
monthPrayersProvider(month)  → FutureProvider.family (월별 기도 목록)
prayerStatsProvider          → FutureProvider<PrayerStats> (writtenDays, streakCount 등)
answeredTitlesProvider       → FutureProvider (기도 제목+응답여부 목록)

profileProvider              → FutureProvider<ProfileModel?>
fontSizeProvider              → StateNotifierProvider<double> (SharedPreferences 연동)

shellTabProvider              → StateProvider<int> (하단 탭 인덱스)
previousTabProvider           → StateProvider<int?> (뒤로가기 복귀용)

selectedCategoryProvider      → StateProvider<String> (커뮤니티 카테고리)
myGroupsProvider               → FutureProvider.autoDispose<List<CommunityGroup>>
groupMembersProvider(groupId) → FutureProvider.autoDispose.family
communityLettersProvider      → FutureProvider.autoDispose (전체 공개 편지)
groupLettersProvider(groupId) → FutureProvider.autoDispose.family
// + createGroup / joinGroupByCode / postCommunityLetter / leaveGroup /
//   deleteGroup / updateGroupName: WidgetRef를 받는 CRUD 함수들

prayerAlarmsProvider          → StateNotifierProvider<List<PrayerAlarm>> (매일 알람)
tomorrowAlarmsProvider        → StateNotifierProvider<List<TomorrowPrayerAlarm>> (1회성 알람)
```

---

## 8. 하단 네비게이션 구조 (main.dart) — 2026-06-17 개편

```
MainShell (탭 인덱스: 0=서신서, 1=기도기록, 2=커뮤니티, 3=설정)
├── [탭 0] HomeScreen
├── [탭 1] RecordScreen
├── [중앙 FAB] + 버튼 (accent 원형) → PrayerWriteScreen 바텀시트
├── [탭 2] CommunityScreen
└── [탭 3] SettingsScreen
```

- 탭 전환: Stack + AnimatedOpacity(200ms) + IgnorePointer (화면 keep-alive)
- **하단 탭 아이콘만 표시, 텍스트 라벨 제거** (아이콘으로만 구분, 깔끔한 룩)
- PopScope: 기도기록/커뮤니티/설정 탭에서 뒤로가기 → 서신서(탭0)로 복귀, 또는 이전 탭으로

---

## 9. 개발 환경

| 항목 | 내용 |
|------|------|
| 실기기 | 갤럭시 S23 (USB 디버깅, ADB) |
| ADB 경로 | `C:\Users\shjou\AppData\Local\Android\Sdk\platform-tools\adb.exe` |
| 에뮬레이터 | 사용 가능 (Cold Boot 필요, 스냅샷 문제) |
| 실행 명령 | `cd C:\Users\shjou\Projects\pray_story` → `flutter run` |
| 빌드 SDK | Dart ^3.11.5 |
| 형상관리 | Git + GitHub (`shjoungdkfus/pray-story`), 2026-06-20부터 추적 시작 |

---

## 10. 진행 경과 요약 (타임라인)

| 날짜 | 내용 |
|------|------|
| ~06-12 | 서신서(홈)/기도작성/검색/설정/인증 핵심 기능 구현, 실기기 테스트 완료 |
| 06-15 | 기도기록 탭(달력·통계·응답체크) 구현, 커뮤니티 기능 명세 작성(`docs/community_spec.md`) + DB 테이블 설계(`docs/community_tables.sql`) |
| 06-17 | 커뮤니티 기능 전체 구현(그룹/편지/초대), 알림·기도알람 기능 추가, 색상 가시성 개선, 탭 제목 글씨체/크기 통일, 기도기록 보조설명 텍스트 제거, 하단 탭 텍스트 라벨 제거 |
| 06-20 | GitHub 저장소 연동, 본 보고서 최신화 |

---

## 11. 코드 파일 경로 일람

| 파일 | 경로 |
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
| 알림 서비스 | `lib/services/notification_service.dart` |
| 로그인 화면 | `lib/screens/auth/auth_screen.dart` |
| 메인 화면 | `lib/screens/home/home_screen.dart` |
| 검색 오버레이 | `lib/screens/home/history_search_overlay.dart` |
| 기도기록 화면 | `lib/screens/record/record_screen.dart` (+ widgets/) |
| 커뮤니티 화면들 | `lib/screens/community/*.dart` (7개) |
| 설정 화면 | `lib/screens/settings/settings_screen.dart` |
| 기도 작성 화면 | `lib/screens/write/prayer_write_screen.dart` |
| 글자크기 피커 | `lib/widgets/font_size_picker_sheet.dart` |
| 알림 시간 피커 | `lib/widgets/notification_picker_sheet.dart` |
| 커뮤니티 기능 명세 | `docs/community_spec.md` |
| 커뮤니티 DB 스키마 | `docs/community_tables.sql` |
| 의존성 정의 | `pubspec.yaml` |

---

*이 보고서는 프로젝트 전체 코드를 기반으로 자동 생성되었습니다.*
