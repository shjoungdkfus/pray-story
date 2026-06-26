# 개발 기록 (CHANGELOG)

매일 개발한 내용을 날짜별로 기록합니다. 최신 날짜가 위로 오도록 추가합니다.

---

## 2026-06-26

### 서신함(아카이브) 화면 구현 및 실데이터 연결

**신규 파일**
- `lib/screens/archive/archive_screen.dart`: 서신함 메인 화면 (ConsumerWidget)
  - `yearPrayersProvider`로 올해 전체 기도 불러오기
  - 월별 책등 상태(completed/current/future) 및 기도 작성일 수 계산
  - 이번 달 봉투 격자에서 날짜 탭 시 서신서 탭으로 이동 + 해당 날짜 선택
  - 오늘 기도 작성 여부에 따라 CTA 카드 상태 변경
- `lib/screens/archive/widgets/month_grid_screen.dart`: 월별 드릴다운 화면 (ConsumerWidget)
  - `monthPrayersProvider`로 해당 월 기도 불러오기
  - 작성일/응답일/빈날/오늘/미래 상태 실데이터 기반으로 렌더링
  - 날짜 탭 시 서신서 탭으로 이동 후 이전 화면 pop

**기존 파일 변경**
- `lib/providers/prayer_provider.dart`: `yearPrayersProvider(int year)` 추가 — 연간 기도 일괄 조회
- `lib/core/constants/app_colors.dart`: 책등 색상 순환 팔레트 6색(`spineColors`) + 금박 장식색(`goldColor`) 추가
- `lib/main.dart`: 서신함 탭(인덱스 1, `local_library` 아이콘) 추가 — 탭 순서 재정렬 (서신서·서신함·FAB·기도기록·커뮤니티·설정)
- `lib/screens/record/record_screen.dart`: 기도기록 탭 인덱스 1→2 수정 (탭 추가에 따른 인덱스 변경 반영)

---

## 2026-06-24

### 스플래시 스크린 시안 추가
- 버건디 배경 / 크림 배경 2종 스플래시 스크린 시안 추가

### Gradle 래퍼 파일 추적
- `gradlew`, `gradlew.bat`, `gradle-wrapper.jar` git 추적에 포함

---

## 2026-06-23

### 앱 아이콘 (Launcher Icon) 적용
- 새로 디자인한 로고(버건디 배경 + 크림색 P+S 펜촉)를 앱 런처 아이콘으로 적용
- `flutter_launcher_icons` 패키지를 사용해 Android 전 해상도(mdpi~xxxhdpi) 아이콘 생성
- **적응형 아이콘(Adaptive Icon)** 추가 구성
  - 로고에서 배경을 투명 처리해 전경(foreground) 이미지로 분리
  - 펜촉 끝부분이 원형 마스크 등에서 잘리지 않도록 안전영역(safe zone) 기준 약 82% 크기로 축소·중앙 정렬
  - 배경색(`#60041B`)을 별도 레이어로 분리하여 삼성(둥근 사각형), Pixel(원형) 등 런처별 마스크 모양에 관계없이 일관되게 표시되도록 함

**변경 파일**
- `pubspec.yaml`: `flutter_launcher_icons` 설정에 `adaptive_icon_background`, `adaptive_icon_foreground` 추가
- `assets/icon/app_icon.png` (신규): 원본 1024x1024 아이콘
- `assets/icon/app_icon_foreground.png` (신규): 배경 투명 처리된 전경 이미지
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: 해상도별 기본 아이콘 갱신
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (신규): 적응형 아이콘 정의
- `android/app/src/main/res/drawable-*/ic_launcher_foreground.png` (신규): 해상도별 전경 이미지
- `android/app/src/main/res/values/colors.xml` (신규): 적응형 아이콘 배경색 정의

### 플레이스토어 배포 준비 검토 (코드 변경 없음, 점검만)
- claude.ai에서 미리 작성된 `DEPLOYMENT_HANDOFF.md`(배포 준비 인수인계 메모)를 실제 코드 상태와 대조 확인
- **앱 표시 이름**: 핸드오프 문서는 "나의 서신서"(한글)로 변경 제안했으나, 직전 세션에서 이미 "PrayStory"(영문)로 변경한 상태를 그대로 **유지하기로 확정**
- **확인된 기존 구현**: `applicationId`(`com.praystory.pray_story`), release 서명 자동 폴백 구조(`build.gradle.kts` + `key.properties.template`)는 이미 핸드오프 문서 제안보다 안전하게 구현돼 있어 추가 작업 불필요
- **다음에 할 일로 확정된 항목** (아직 미착수):
  1. 실제 릴리즈 키스토어(.jks) 생성 + `android/key.properties` 작성 — 배포 차단 요소, 최우선
  2. ProGuard 설정 추가 (`proguard-rules.pro` 생성 + `build.gradle.kts` release 블록에 `isMinifyEnabled`/`isShrinkResources`)
  3. `flutter build appbundle --release` 릴리즈 빌드 + 실기기 사전 확인
  4. Play Console 등록 자산: 스크린샷, 짧은/자세한 설명문, 개인정보처리방침 (모두 미작성)

### 회원가입 비밀번호 검증 및 에러 메시지 개선
- 비밀번호 최소 길이 검증 추가
- 비밀번호 불일치 등 구체적인 한국어 에러 메시지 표시

### 기도 기록 알림 UI 버그 3건 수정
- 기도 기록 탭 알림 관련 UI 렌더링 버그 수정

### 설정 화면 프로필 수정 기능 추가
- 설정 화면에서 닉네임·프로필 정보 수정 가능하도록 UI 추가
