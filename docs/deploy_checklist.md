# 배포/업데이트 체크리스트

## 매 업데이트마다 해야 하는 작업 (자동 아님)
- `pubspec.yaml` 버전 bump (`versionCode`는 이전 값보다 커야 재업로드 가능)
- `flutter build appbundle --release` 로 AAB 재빌드
- Play Console에 업로드 + 심사 대기 (통상 몇 시간~하루)
- 업데이트가 잦아지면 GitHub Actions + Fastlane 또는 Google Play Publishing API로 빌드/업로드 자동화 고려

## 한 번 설정하면 유지되는 것
- 스토어 등록정보(이름/설명/스크린샷) — 기능이 크게 안 바뀌면 그대로 둬도 됨
- `android/key.properties` + `upload-keystore.jks` (서명 키, git 미추적 유지)
- 개인정보처리방침 URL (GitHub Pages: `docs/privacy_policy.html`, `docs/privacy_policy_en.html`)

---

## 향후 기능 추가 시 Play Console에서 반드시 다시 확인할 것

### AI 분석 (여러 기도 기록 기반 AI 분석 기능)
- 기도 기록을 외부 AI API로 전송한다면 Play Console **"데이터 보안(Data safety)" 섹션 갱신 필수**
  (누락 시 정책 위반으로 반려될 수 있음)
- `privacy_policy.md` / `privacy_policy_en.md`에 "AI 처리 목적 데이터 전송" 명시
- 어떤 데이터가 전송되는지, 저장/보존 기간, 제3자(AI 제공사) 공유 여부 구체적으로 기재

### 커뮤니티 활성화 / 익명 중보기도 (사용자 생성 콘텐츠 확대)
- UGC(사용자 생성 콘텐츠)가 늘어나면 신고/차단 기능 필요 (Google의 UGC 앱 심사 기준이 더 까다로움)
- 콘텐츠 등급 재검토 필요할 수 있음
- 스팸/괴롭힘 방지, 신고 처리 프로세스 마련 권장

---

## Play Console 콘텐츠 등급 / 데이터 보안 양식 초안 (2026-07-12 작성)

### 콘텐츠 등급 설문 (IARC)
- 폭력/성적 콘텐츠/욕설/도박: 전부 "해당 없음"
- "사용자 간 상호작용(커뮤니케이션)" 질문: **예** (커뮤니티 편지 기능 때문)
- 예상 등급: 전체이용가

### 데이터 보안(Data safety) 양식

**수집 데이터**

| 유형 | 수집 | 필수/선택 | 목적 |
|---|---|---|---|
| 이름 | 예 | 필수 | 앱 기능, 계정 관리 |
| 이메일 주소 | 예 | 필수 | 앱 기능, 계정 관리 |
| 사용자 ID | 예 | 필수 | 앱 기능, 계정 관리 |
| 기타 개인정보 (교회, 출생연도, 성별) | 예 | 선택 | 앱 기능 |
| 사용자 제작 콘텐츠 (기도 기록, 커뮤니티 편지) | 예 | 필수 | 앱 기능 |

- 공유 여부: 제3자와 데이터 공유 **안 함** (Supabase는 데이터 처리자로 분류, Google/Kakao는 인증 목적만)
- 전송 중 암호화: 예 (Supabase HTTPS/TLS)
- 사용자 데이터 삭제 요청 가능: 예 (설정 > 계정 탈퇴 기능, `account_screen.dart`)

⚠️ 확인 필요: "소중한 이에게" 익명 편지가 특정 상대 대상 다이렉트 메시지 방식이면 Play의 "Messages" 카테고리로도 잡힐 수 있음. 전체/그룹 공개 피드 형태면 위 "사용자 제작 콘텐츠"로 충분. 실제 UI 동작 방식에 맞게 Play Console에서 최종 판단.

---

## 2026-07-12 세션 진행상황

### 오늘 완료한 것
- 저장소 Public 전환 + GitHub Pages 활성화 (`master`/`docs`) → 개인정보처리방침 URL 확보 및 200 OK 확인
  - KO: `https://shjoungdkfus.github.io/pray-story/privacy_policy.html`
  - EN: `https://shjoungdkfus.github.io/pray-story/privacy_policy_en.html`
- 스토어 짧은 설명 **B(기능 중심)** 확정 (`store_listing.md` 반영)
- Play Console 콘텐츠 등급 / 데이터 보안 양식 초안 작성 (위 섹션)
- `applicationId`(`com.praystory.pray_story`) 외부 서비스 등록 상태 점검
  - Google Cloud Console (OAuth 클라이언트, 릴리즈 SHA-1 `0C:2C:32:5A:9F:96:43:EB:48:7F:AB:4B:E6:B9:DB:E2:00:A3:72:BD`) — 사용자 확인 완료
  - Supabase Auth Redirect URL — 사용자 확인 완료
  - Kakao Developers:
    - Redirect URI (`https://ljtsytknzfcuahqtbmqe.supabase.co/auth/v1/callback`) — 등록 확인됨 ✅
    - 클라이언트 시크릿 활성화(ON) 발견 — **Supabase Kakao Provider 쪽 Client Secret 값 일치 여부 다음 세션에 확인 필요**
    - 네이티브 앱 키 → Android 플랫폼에 패키지명(`com.praystory.pray_story`) + 릴리즈 키 해시(`DCwyWp+WQ+tIf6tL5rnb4gCjcr0=`) 입력 후 저장 (세션 종료 시점 기준 저장 직후, 최종 화면 재확인은 다음 세션)
- Play Console 개인 개발자 계정 가입/본인인증/전화번호 인증 — 사용자가 별도 진행 (콘솔 내부 정보라 Claude Code에서 검증 불가)

### 점검 결과 정정된 것 (이전에 다른 곳에 기록했던 체크리스트 대비)
- 개인정보처리방침 호스팅: "URL 없음" → 실제로는 이미 완료
- AAB/APK 빌드: "완료" → 실제로는 **7/9 18:24 빌드로 구버전** (7/12 다크모드 개편 등 이후 커밋 미반영, 최종 단계에 재빌드 예정이라 계획대로면 문제 없음)
- 스플래시 스크린: "미확인" → 실제로는 **적용 안 됨 확정** (`assets/splash/`에 A/B 시안 파일만 존재, `launch_background.xml`은 Flutter 기본 템플릿 그대로, Dart 코드에서 참조 없음)

### 다음 세션에 이어할 것 (우선순위 순)
1. Kakao 네이티브 앱 키 저장 완료 화면 확인
2. Supabase Authentication → Providers → Kakao의 Client Secret 값이 Kakao 콘솔과 일치하는지 확인
3. 스플래시 스크린 적용 (A/B 시안 중 택1, `launch_background.xml` + native 스타일 연결)
4. 실기기(갤럭시 S23) 릴리즈 빌드 테스트 — 로그인/알림/딥링크(OAuth) 등 ProGuard 영향 확인이 핵심
5. Play Console: 앱 생성 완료 → 스토어 등록정보/콘텐츠 등급/데이터 보안 양식 제출 → 테스트 계정 준비
6. AAB 최종 재빌드 (위 항목 전부 끝난 뒤 맨 마지막에)
7. 내부 테스트 트랙 설정, 테스터 12명 이메일 확보, 14일 비공개 테스트 진행

---

## 2026-07-13 세션 진행상황

### 오늘 완료한 것
- Kakao 네이티브 앱 키 저장 / Supabase Client Secret 일치 확인 — 사용자가 세션 시작 전 완료 확인 (위 1, 2번)
- **스플래시 스크린 적용** (`flutter_native_splash` 패키지 도입)
  - 아이콘(`assets/icon/app_icon.png`)을 70% → 35% → 28%로 단계적으로 축소한 `assets/icon/splash_logo.png` 생성 (원본 캔버스 크기 유지한 채 흰 여백 추가 — 아이콘 자체의 크림→흰색 페이드와 자연스럽게 이어짐)
  - 처음엔 라이트/다크 배경색을 분리(`#FFFFFF`/`#000000`)했으나, **Android 12+ 스플래시 API가 아이콘 뒤에 흰색 원형 배경을 강제로 씌우는 시스템 동작 때문에 다크 모드에서 흰 카드가 뜨는 문제 발견** → 다크 대응 제거하고 **라이트(흰색)로 통일**해서 해결
  - 실기기(갤럭시 S23, `adb shell cmd uimode night yes/no`로 다크모드 토글)에서 라이트/다크 양쪽 다 스크린샷으로 최종 확인 완료
- 다크 모드 UI 밝기 3건 수정 (`lib/core/constants/app_colors.dart`)
  - 기록 화면 통계 카드 숫자: 고정 회색(`accent`) → `textPrimary`(다크에서 크림빛 흰색으로 밝게)
  - 달력 기록 표시 원(`calendarMark`) 다크 모드: `#9A948A` → `#B5AFA3`
  - 설정 타일 아이콘(`settingsIcon`) 다크 모드: `#6E6A63` → `#8F897F`
- 계정 화면 로그아웃/회원탈퇴 확인 다이얼로그 버튼 색상 수정 (`lib/screens/settings/account_screen.dart`)
  - 기존 고정 회색이라 흐릿하게 보이던 문제 → 로그아웃은 `textPrimary`(적응형), 회원탈퇴는 신규 고정 색상 `AppColors.danger`(`#C0392B`, 라이트/다크 동일)로 분리
- 커밋 3건, 모두 `origin/master`에 push 완료
  - `e642295` 스플래시 스크린 적용 및 다크 모드 밝기 개선
  - `e598232` 스플래시 화면 다크 모드 대응 제거, 라이트(흰색)로 통일
  - `c183221` 계정 화면 로그아웃/회원탈퇴 확인 버튼 색상 강조

### 참고
- `pubspec.lock`이 `flutter_native_splash` 추가로 갱신됐지만, 기존 패키지 버전은 전혀 바뀌지 않음(신규 transitive 의존성만 추가) — 확인 완료
- 모든 확인은 `flutter run --debug`(실기기 갤럭시 S23) 기준. **release 빌드/ProGuard 영향은 아직 미검증**

### 다음 세션에 이어할 것 (우선순위 순)
1. 실기기(갤럭시 S23) **release 빌드** 테스트 — 로그인/알림/딥링크(OAuth) 등 ProGuard 영향 확인 (오늘 변경분 포함해서 처음 하는 release 검증)
2. Play Console: 앱 생성 완료 → 스토어 등록정보/콘텐츠 등급/데이터 보안 양식 제출 → 테스트 계정 준비
3. `pubspec.yaml` 버전 bump (`1.0.0+1` 그대로 — 최종 재빌드 직전에 반드시 올릴 것)
4. AAB 최종 재빌드 (위 항목 전부 끝난 뒤 맨 마지막에)
5. 내부 테스트 트랙 설정, 테스터 12명 이메일 확보, 14일 비공개 테스트 진행

---

## 2026-07-14 세션 진행상황

### 오늘 완료한 것 — Play Console "로그인 세부정보"(구 앱 액세스) 작성
- **"앱에 제한된 부분이 있나요?"** → **예** 선택 (이메일/구글/카카오 계정 로그인 없이는 앱 기능 접근 불가하므로)
- **리뷰어용 테스트 계정 생성**: 새 구글 계정 안 만들고 Gmail 플러스 별칭 사용
  - 이메일: `shjoung0+praystoryreview@gmail.com` (실제로는 `shjoung0@gmail.com` 받은편지함으로 수신, Supabase 입장에선 별개 계정)
  - 앱 내 이메일/비밀번호 회원가입으로 생성, 이름 `테스터`로 가입 (교회/성별/생년은 비움)
  - Supabase Authentication → Email 설정에서 **"Confirm email" 토글이 꺼져 있음을 확인** → 가입 즉시 로그인 가능한 상태로 확인 완료 (인증 메일 절차 불필요)
  - 로그아웃 후 이메일/비밀번호로 재로그인 성공 확인
- **로그인 세부정보 입력값**:
  - 이름: `이메일/비밀번호 로그인`
  - 사용자 이메일: `shjoung0+praystoryreview@gmail.com`
  - 비밀번호: `PrayReview2026!`
  - 기타 정보: "로그인 화면에서 이메일/비밀번호 입력 후 로그인 버튼을 눌러주세요. 카카오/구글 소셜 로그인 버튼은 사용하지 않아도 됩니다."
- **광고(Ads) 섹션** 확인: `pubspec.yaml`/`AndroidManifest.xml`에 광고 SDK(AdMob 등) 전혀 없음 확인 → **"아니요, 앱에 광고가 없습니다"** 선택 예정 (화면까지만 확인, 실제 저장/제출은 다음 세션에 이어서)

### 다음 세션에 이어할 것 (우선순위 순)
1. Play Console "광고" 섹션 — "아니요" 선택 후 저장, 이어지는 다른 설문(콘텐츠 등급/데이터 보안 등 나머지 섹션) 계속 진행
2. 실기기(갤럭시 S23) **release 빌드** 테스트 — 로그인/알림/딥링크(OAuth) 등 ProGuard 영향 확인 (아직 미검증)
3. Play Console: 스토어 등록정보/콘텐츠 등급/데이터 보안 양식 최종 제출 → 테스트 계정 준비 완료됨(위 참고)
4. `pubspec.yaml` 버전 bump (`1.0.0+1` 그대로 — 최종 재빌드 직전에 반드시 올릴 것)
5. AAB 최종 재빌드 (위 항목 전부 끝난 뒤 맨 마지막에)
6. 내부 테스트 트랙 설정, 테스터 12명 이메일 확보, 14일 비공개 테스트 진행
