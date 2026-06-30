# 나의 서신서 (PrayStory)

> "하나님이 오늘 나를 통해 써 내려가시는 양장 성경책" — 기도 일기 + 기도 커뮤니티 Android 앱

## 기술 스택

- **Flutter** (Riverpod 상태 관리, GowunBatang 폰트)
- **Supabase** (Auth + PostgreSQL + RLS)
- **Android** (플레이스토어 배포 준비 완료 — 릴리즈 키스토어·ProGuard 적용)

## 주요 화면

| 탭 | 기능 |
|----|------|
| 서신서 | 날짜별 기도 일기 (양면 성경책 UI, 페이지 스와이프, 원고지 배경) |
| 기도기록 | 달력 + 통계(기록일·연속일) + 기도 제목·응답 목록 |
| +(FAB 중앙) | 기도 작성 / 수정 |
| 기도 서신 | 그룹 만들기·참여, 편지 피드, 중보 반응(함께 기도) |
| 설정 | 내 정보 수정, 알림 설정, 피드백, 계정(탈퇴) |

## 빠른 시작

```bash
cd C:\Users\shjou\Projects\pray_story
flutter run                          # 디버그 (갤럭시 S23 USB)
flutter build appbundle --release    # 릴리즈 AAB
```

## 문서

| 파일 | 내용 |
|------|------|
| [`PROJECT_REPORT.md`](PROJECT_REPORT.md) | 전체 기술 명세 — DB 스키마·화면 명세·상태 관리·파일 목록 |
| [`CHANGELOG.md`](CHANGELOG.md) | 날짜별 개발 기록 (새 세션 시작 시 먼저 읽을 것) |
| [`docs/community_tables.sql`](docs/community_tables.sql) | 커뮤니티 DB 스키마 v1 |
| [`docs/community_v2.sql`](docs/community_v2.sql) | 커뮤니티 DB 스키마 v2 (그룹 공지·중보) |
| [`docs/feedback_table.sql`](docs/feedback_table.sql) | 피드백·회원탈퇴 DB 스키마 |
