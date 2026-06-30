# 개발 기록 (CHANGELOG)

매일 개발한 내용을 날짜별로 기록합니다. 최신 날짜가 위로 오도록 추가합니다.

---

## 2026-06-30

### 탭 헤더 정렬 통일 — 서브탭 제목 좌측 정렬
- 기도기록·설정 탭 제목을 가운데에서 좌측으로 변경 (커뮤니티는 이미 좌측, 홈 날짜는 가운데 유지)
- **변경 파일**: `record_screen.dart`, `settings_screen.dart`

---

### 설정 탭 전면 재디자인 + 기능 확장
그룹형 설정 허브로 개편, 항목별 상세 페이지(Navigator.push) 구조.

**신규 파일**
- `lib/providers/settings_provider.dart`: `themeModeProvider`(AppThemeMode), `languageProvider`(AppLanguage) — SharedPreferences 저장만, MaterialApp 미연결(라이트 유지)
- `lib/screens/settings/widgets/settings_kit.dart`: 재사용 위젯 모음(SettingsDetailScaffold, SettingsGroup, SettingsTile, SettingsProfileHeader, SettingsRadioTile)
- `lib/screens/settings/profile_edit_screen.dart`: 내 정보 풀페이지(이름/생년월일/성별, profiles upsert)
- `lib/screens/settings/app_settings_screen.dart`: 앱설정(알림 푸시 / 테마·언어 바텀시트)
- `lib/screens/settings/notification_settings_screen.dart`: 매일 기도 알람 UI — 기존 `prayerAlarmsProvider`에 처음으로 UI 연결(시간 추가/토글/삭제)
- `lib/screens/settings/feedback_screen.dart`: 피드백(유형칩+내용), Supabase `feedback` 테이블 insert + url_launcher mailto 동시 지원, 관리자 메일 `shjoung0@gmail.com`
- `lib/screens/settings/account_screen.dart`: 계정(로그아웃/회원탈퇴), 탈퇴는 소프트 삭제(`profiles.deleted_at` 표시 + signOut)
- `docs/feedback_table.sql`: `feedback` 테이블+RLS + `profiles.deleted_at` 컬럼 추가 SQL

**변경 파일**
- `pubspec.yaml`: `url_launcher: ^6.3.1` 추가
- `AndroidManifest.xml`: `<queries>`에 mailto(SENDTO) intent 추가 (Android 11+ 메일앱 가시성)

**DB 마이그레이션 (Supabase에서 실행 필요)**
- `docs/feedback_table.sql` 실행 필요

---

### ProGuard 보완 + 홈 화면 UX 수정
- `proguard-rules.pro`: JNI 브릿지(`com.github.dart_lang.jni.**`) + app_links(`com.llfbandit.app_links.**`) keep 규칙 추가
- `home_screen.dart`: 홈 안내문 수직 중앙 배치, 빈 페이지 탭→쓰기, 글 있을 때 탭→수정, 빈 공간 탭→새 글 쓰기 복구

---

## 2026-06-29 (오후) — 커뮤니티 그룹 상세 재디자인

### 그룹 상세 화면 전면 개편 (공지 / 서신 / 멤버 + 중보 반응)
타 기도 앱 UI 참고하여 우리 감성으로 재설계.

**신규 파일**
- `lib/screens/community/group_detail_screen.dart`: 세그먼트 탭(공지/서신/멤버) 구조의 그룹 상세
  - 헤더: 이모지 아이콘 + 모임명 + 한 줄 설명 + ≡ 메뉴 버튼
  - 서신 카드에 "함께 기도" 중보 반응 — 누르면 카운트 증가 + 함께한 사람 아바타 스택 표시
  - 공지: 금색 카드(방장만 등록/삭제), 멤버: 방장 배지 + 방장의 멤버 내보내기
  - 우하단 알약형 "추가하기" FAB → 바텀시트(편지 쓰기 / 공지 등록 / 멤버 초대)
  - ≡ 메뉴: 모임 이름·설명·아이콘 변경, 멤버 권한 관리, 나가기(방장은 삭제), 이모지 아이콘 피커(12종)
- `lib/screens/community/notice_write_screen.dart`: 공지 작성 화면

**DB 마이그레이션 (Supabase에서 실행 필요)**
- `docs/community_v2.sql`:
  - `community_groups`에 `description`, `icon` 컬럼 추가
  - `group_notices` 테이블 신규 (방장 공지 + RLS)
  - `letter_prayers` 테이블 신규 (서신 중보 반응 + RLS)

**기존 파일 변경**
- `models/community_models.dart`: `CommunityGroup`에 description/icon 추가, `GroupNotice`·`LetterPrayerInfo` 모델 신규
- `providers/community_provider.dart`: `groupNoticesProvider`, `letterPrayerProvider` + 공지 작성/삭제, 중보 토글, 설명/아이콘 변경, 멤버 내보내기 함수 추가
- `screens/community/community_screen.dart`: 그룹 탭 시 GroupDetailScreen으로 push (구 inline `_GroupDetailView` 제거)

---

## 2026-06-29 — 전체 UI 대규모 리팩토링

### 서신함 탭 제거 및 각 화면 정리
**제거**
- 서신함(아카이브) 탭 및 `lib/screens/archive/` 하위 파일 전체 삭제
- `app_colors.dart`: 서신함 전용 색상(`spineColors`, `goldColor`) 제거
- `prayer_provider.dart`: `yearPrayersProvider` 제거

**변경**
- `main.dart`: 탭 구성 4개로 복귀 (서신서·기도기록·커뮤니티·설정) + 중앙 FAB
- `record_screen.dart`: 월간/주간 토글 제거 → 달력 + 지난 기록 + 검색바 구성으로 단순화
- `stats_summary_row.dart`: 통계 카드 "이번 달 기록 / 응답 기록" 2개로 정리
- `home_screen.dart`, `prayer_write_screen.dart`, `history_search_overlay.dart`: 코드 정리

**신규**
- `lib/screens/record/widgets/recent_records_section.dart`: 기도 기록 탭 하단 "지난 기록" 리스트 위젯 분리

---

## 2026-06-24

### 스플래시 스크린 시안 추가
- 버건디 배경 / 크림 배경 2종 스플래시 스크린 시안 추가

### Gradle 래퍼 파일 추적
- `gradlew`, `gradlew.bat`, `gradle-wrapper.jar` git 추적에 포함

---

## 2026-06-23

### 릴리즈 키스토어 생성 + ProGuard 설정 + 빌드 검증
- 릴리즈 키스토어 생성: `android/upload-keystore.jks` (alias `upload`, RSA 2048, 유효기간 ~2053년)
- `android/key.properties` 작성 (git 제외 — `.gitignore`에 등록됨)
- `android/app/proguard-rules.pro` 신규: Flutter deferred components + `flutter_local_notifications` keep 규칙
- `build.gradle.kts` release 블록: `isMinifyEnabled=true`, `isShrinkResources=true`, `proguardFiles(...)` 추가
- `flutter build appbundle --release` 성공 (43.5MB), `flutter build apk --release` 성공 (55.0MB)
- 갤럭시 S23 릴리즈 APK 설치 검증 완료 (회원가입 화면 정상, 크래시 없음)

### 앱 아이콘 (Launcher Icon) 적용
- 새로 디자인한 로고(버건디 배경 + 크림색 P+S 펜촉)를 앱 런처 아이콘으로 적용
- `flutter_launcher_icons` 패키지로 Android 전 해상도(mdpi~xxxhdpi) 아이콘 생성
- **적응형 아이콘(Adaptive Icon)**: 전경 이미지 분리, 안전영역 기준 82% 축소·중앙 정렬, 배경색(`#60041B`) 별도 레이어 — 런처별 마스크 모양과 무관하게 일관 표시
- **변경 파일**: `pubspec.yaml`, `assets/icon/app_icon.png` (신규), `assets/icon/app_icon_foreground.png` (신규), `android/app/src/main/res/mipmap-*`, `android/app/src/main/res/values/colors.xml`

### 플레이스토어 배포 준비 검토 (코드 변경 없음)
- `DEPLOYMENT_HANDOFF.md`를 실제 코드와 대조 확인
- **앱 표시 이름**: "PrayStory"(영문) 유지 확정
- `applicationId`(`com.praystory.pray_story`), release 서명 폴백 구조 이미 안전하게 구현됨

### 회원가입 비밀번호 검증 및 에러 메시지 개선
- 비밀번호 최소 길이 검증 추가, 한국어 에러 메시지 표시

### 기도 기록 알림 UI 버그 3건 수정

### 설정 화면 프로필 수정 기능 추가
- 설정 화면에서 닉네임·프로필 정보 수정 가능하도록 UI 추가
