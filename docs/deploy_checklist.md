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
