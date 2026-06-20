# 나의 서신서 (Pray_Story) — 프로젝트 전체 보고서

> 작성일: 2026-06-12  
> 작성자: Claude (AI 코드 어시스턴트)

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 이름 | 나의 서신서 (Pray_Story) |
| 컨셉 | "하나님이 오늘 나를 통해 써 내려가시는 양장 성경책 감성 UI" |
| 목적 | 개인 기도 일기 기록 앱 |
| 플랫폼 | Android (Flutter) |
| 개발 상태 | 핵심 기능 전체 구현 완료 / 실기기 테스트 완료 |

---

## 2. 기술 스택

### Flutter 패키지 (pubspec.yaml)
```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # 상태 관리
  supabase_flutter: ^2.9.0      # 백엔드 (DB + 인증)
  google_fonts: ^6.2.1          # GowunBatang 폰트
  intl: ^0.20.2                 # 날짜 포맷 / 한국어
  shared_preferences: ^2.3.3   # 로컬 설정 저장 (글자크기)
  flutter_localizations         # 한국어 로케일 (Cupertino 피커용)
  cupertino_icons: ^1.0.8
```

### 백엔드: Supabase
- **프로젝트명:** Pray-story
- **URL:** `https://ljtsytknzfcuahqtbmqe.supabase.co`
- **Anon Key:** `sb_publishable_9GFmKPM7t9S5wXIwaUe9WQ_mpvU8LmC`
- **이메일 인증:** OFF (개발 편의)

---

## 3. 디자인 시스템

### 컬러 팔레트 (AppColors)
| 이름 | HEX | 용도 |
|------|-----|------|
| background | `#FEFCF8` | 앱 전체 배경 (거의 흰색, 미세한 크림) |
| card | `#FDF9F2` | 카드, 바텀시트 배경 |
| searchBar | `#F6F0E1` | 하단 검색바 영역 |
| bottomBar | `#EFE6D0` | 하단 탭바 배경 |
| textPrimary | `#3A2418` | 본문 텍스트 (소프트 브라운) |
| accent | `#A93226` | 강조색 (부드러운 레드) |
| textHint | `#9A8878` | 힌트/비활성 텍스트 |
| divider | `#DDD0BB` | 구분선 |

### 폰트
- **GowunBatang** (Google Fonts) — 한국 붓글씨 감성, 전체 앱에 적용

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

---

## 5. 앱 구조 (파일 트리)

```
lib/
├── main.dart                          # 앱 진입점, MainShell (하단 탭바)
├── core/
│   ├── constants/
│   │   └── app_colors.dart            # 전체 컬러 팔레트
│   └── supabase/
│       └── supabase_config.dart       # URL, Anon Key
├── models/
│   ├── prayer_model.dart              # 기도 데이터 모델
│   └── profile_model.dart             # 유저 프로필 모델
├── providers/
│   ├── auth_provider.dart             # 인증 상태 Provider
│   ├── prayer_provider.dart           # 기도 데이터 + 검색 Provider
│   ├── profile_provider.dart          # 프로필 Provider
│   └── font_size_provider.dart        # 글자크기 Provider (SharedPreferences)
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart           # 로그인 / 회원가입
│   ├── home/
│   │   ├── home_screen.dart           # 메인 성경책 뷰
│   │   └── history_search_overlay.dart # 하단 검색바 + 슬라이드 결과
│   ├── settings/
│   │   └── settings_screen.dart       # 프로필 정보 + 로그아웃
│   └── write/
│       └── prayer_write_screen.dart   # 기도 작성 / 수정
└── widgets/
    └── font_size_picker_sheet.dart    # 글자크기 선택 바텀시트
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
- **_BookContainer:** 성경책 모양 컨테이너 (그림자, border-radius 4)
- **_BookPage:** 날짜별 기도 목록 표시
- **_PrayerEntry:** 기도 항목 (ConsumerWidget, fontSizeProvider 적용)
  - 제목: accent 색상, fontSize+3, bold, 밑줄
  - 내용: textPrimary, fontSize, height 2.2, 밑줄
  - 타임스탬프: 우측 하단 (작성 시각 / 수정 시각)
  - 탭 → 수정 바텀시트 열기
- **_UnderlinedText + _UnderlinePainter:** CustomPainter로 텍스트 행마다 밑줄
- **글자크기 FAB:** 우하단 (검색바 바로 위), format_size 아이콘
- **_SearchBarFabLocation:** FAB 위치 커스텀 클래스
- **_PrewarmWidget:** 현재 날짜 ±2일 데이터 prefetch

### 6-3. 기도 작성/수정 화면 (prayer_write_screen.dart)
- **모드:** 새 기도 작성(`targetDate`) / 기존 기도 수정(`prayer`)
- **배경:** CustomPainter로 원고지 줄 그리기 (_NoteLinesPainter)
- **저장 조건:** content 비어있으면 불가 / 수정 모드 시 변경사항 있을 때만 가능
- **날짜 처리:** 오늘 → 현재 시각 UTC / 과거 → 정오 sentinel UTC
- **상단 AppBar:** 닫기, 제목, 글자크기 아이콘, 기록하기/수정하기 버튼

### 6-4. 검색 오버레이 (history_search_overlay.dart)
- 하단 검색바 항상 표시
- 입력 시 SizeTransition으로 결과창 슬라이드업
- Supabase `ilike` 쿼리로 title + content 동시 검색
- 결과 탭 → 해당 날짜 페이지로 이동
- 최대 20건 결과

### 6-5. 설정 화면 (settings_screen.dart)
- 이름, 생년월일, 성별, 이메일 표시 (profiles 테이블)
- 로그아웃 버튼

### 6-6. 글자크기 피커 (font_size_picker_sheet.dart)
- 작게(11.0) / 보통(15.0) / 크게(25.0) 3단계
- '가' 미리보기로 크기 직관적 비교
- 선택 시 SharedPreferences 저장 (`prayer_font_size`)

---

## 7. 상태 관리 구조 (Riverpod)

```
supabaseProvider            → Supabase.instance.client
authStateProvider           → Stream<AuthState>
currentUserProvider         → User? (authState에서 추출)
selectedDateProvider        → StateProvider<DateTime> (현재 선택된 날짜)
prayersForDateProvider(date)→ FutureProvider.family (날짜별 기도 목록)
searchQueryProvider         → StateProvider<String>
searchResultsProvider       → FutureProvider (검색 결과)
profileProvider             → FutureProvider<ProfileModel?>
fontSizeProvider            → StateNotifierProvider<double> (SharedPreferences 연동)
```

---

## 8. 하단 네비게이션 구조 (main.dart)

```
MainShell
├── [탭 0] HomeScreen (서신서)
├── [중앙 FAB] + 버튼 → PrayerWriteScreen (바텀시트)
└── [탭 1] SettingsScreen (설정)
```

- 탭 전환: AnimatedOpacity (200ms) + IgnorePointer로 부드럽게 전환
- 중앙 + 버튼: 현재 선택된 날짜에 새 기도 작성

---

## 9. 개발 환경

| 항목 | 내용 |
|------|------|
| 실기기 | 갤럭시 S23 (USB 디버깅, ADB) |
| ADB 경로 | `C:\Users\shjou\AppData\Local\Android\Sdk\platform-tools\adb.exe` |
| 에뮬레이터 | 사용 가능 (Cold Boot 필요, 스냅샷 문제) |
| 실행 명령 | `cd C:\Users\shjou\Projects\pray_story` → `flutter run` |
| 빌드 SDK | Dart ^3.11.5 |

---

## 10. 향후 논의된 기능 아이디어

### 기도 기록 통계 탭 (미결정)

**방향 A — 기록 여부 = 달성 (히트맵 달력 추천)**
- 기도를 쓴 날 = 달성으로 간주
- 추가 테이블 없이 현재 DB로 바로 구현 가능
- GitHub 잔디처럼 쌓이는 히트맵 UI
- 이번 달 기도 일수 / 연속 기도 일수 표시

**방향 B — 기도 제목 사전 등록 + 응답 체크**
- 기도 제목을 미리 등록하고 응답 여부 체크
- 새 테이블(`prayer_goals`) 필요
- 더 풍성한 기능, 개발 범위 넓음

**UI 후보**
1. 히트맵 달력 (추천) — GowunBatang 감성 갈색톤
2. 성경책 감성 월간 뷰 — 날짜를 도장처럼 표시
3. 주간 스트릭 + 월달력 혼합 — 숫자 정보 가장 많음

> 아직 구현 미착수. 방향 결정 후 진행 예정.

---

## 11. 코드 파일 경로 일람

| 파일 | 경로 |
|------|------|
| 앱 진입점 | `lib/main.dart` |
| 컬러 | `lib/core/constants/app_colors.dart` |
| Supabase 설정 | `lib/core/supabase/supabase_config.dart` |
| 기도 모델 | `lib/models/prayer_model.dart` |
| 프로필 모델 | `lib/models/profile_model.dart` |
| 인증 Provider | `lib/providers/auth_provider.dart` |
| 기도 Provider | `lib/providers/prayer_provider.dart` |
| 프로필 Provider | `lib/providers/profile_provider.dart` |
| 글자크기 Provider | `lib/providers/font_size_provider.dart` |
| 로그인 화면 | `lib/screens/auth/auth_screen.dart` |
| 메인 화면 | `lib/screens/home/home_screen.dart` |
| 검색 오버레이 | `lib/screens/home/history_search_overlay.dart` |
| 설정 화면 | `lib/screens/settings/settings_screen.dart` |
| 기도 작성 화면 | `lib/screens/write/prayer_write_screen.dart` |
| 글자크기 피커 | `lib/widgets/font_size_picker_sheet.dart` |
| 의존성 정의 | `pubspec.yaml` |

---

*이 보고서는 프로젝트 전체 코드를 기반으로 자동 생성되었습니다.*
