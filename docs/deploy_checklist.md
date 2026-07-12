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
