# QA 3단계 — 액션 검증 매트릭스 (02_action_matrix.md)

> `docs/PRAYSTORY_QA_PROMPT_v2.md` E절 12항목 체크리스트 기준. 대상: `qa/00_inventory.md` §1-2 전 요소 + 2단계 플로우 맥락(`qa/01_flowmap.md`).
> 판정: PASS / FAIL / 미확인(사유). PASS도 근거 라인 남김. FAIL은 `qa/04_defects.md`로 승격.
> 작성일 2026-07-25, 코드 재확인 기반(정적 분석 — 실기기 조작 아님).
>
> **★ 2026-07-25 — `PS-ACT-01~05` 전부 수정 완료.** `PS-A11Y-01`만 백로그로 남김(자체 수정제안에서도 "우선순위 낮음, 일괄처리 권장"으로 명시했던 항목). 아래 표의 판정은 발견 당시 스냅샷 그대로 두고, 각 결함의 수정 여부는 `qa/04_defects.md`의 "상태" 필드가 최신 정보임.

## 공통 결함(전 요소에 반복 적용 — 개별 행에서는 태그만 표기)

| 태그 | 내용 | 근거 | 처리 |
|---|---|---|---|
| **공통-A** | 위젯 테스트용 `Key` 사실상 전무 | `Grep Key\(` 앱 전체 3건 중 2건은 `super.key`/`GlobalKey`(테스트용 아님), 나머지 1건(`prayer_calendar.dart:183`)도 `PageView` 내부용 `ValueKey`일 뿐 테스트 목적 아님 → **실질 테스트 Key 0건** | 체크리스트 원문이 "없으면 추가 제안만"이라 결함 승격 안 함 — 9단계(테스트 자동화) 착수 시 함께 부여 권장 |
| **공통-B** | 아이콘 온리 버튼에 `tooltip`/`Semantics` 라벨 0건 | `Grep tooltip:` 0건, `Grep Semantics\(` 0건 (앱 전체) | 스크린리더 접근성 저하 → 결함 승격(`PS-A11Y-01`, 아래) |

---

## 로그인/회원가입

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 이메일/비번 입력 | `login_screen.dart:137-150` | PASS | 제출 시 `_login()`에서 빈값 검증(스낵바), disable조건 별도 없음(빈값 제출 허용 후 서버단 검증) — FR 불일치 아님 |
| 비번 표시 토글 | `:141-150` | PASS | `setState` 즉시 반영, 파괴적 아님, 공통-B(아이콘, tooltip 없음) 해당하나 토글 상태는 아이콘 모양으로 자체 표현됨 |
| 로그인 버튼 | `:152-156` | PASS | `_isLoading` dup-tap 방지(`:41,154`), 로딩 스피너 표시(`:155`), `mounted` 체크 후 로딩 해제(`:51`) |
| 카카오 버튼 | `:160-166` | PASS | 동일 `_isLoading` 가드(`:165`), 외부 브라우저 전환이라 결과 수신은 `authStateProvider` 스트림으로 처리(별도 mounted 불필요) |
| 구글 버튼 | `:168-176` | PASS | 동일 가드(`:175`), `mounted` 체크 확인(`:82,100`) |
| "회원가입" 링크 | `:188-205` | PASS | 단순 push, 부작용 없음 |
| Signup1 입력 3종 | `signup_step1_screen.dart:103-121` | PASS | `_next()`에서 정규식+길이+일치 검증(`:42-54`), 실패 시 스낵바 |
| Signup1 다음 버튼 | `:177-203` | PASS | 네트워크 호출 없음(미가입 상태로 값만 전달) — dup-tap 위험 자체가 없음 |
| Signup2 이름 | `profile_form.dart:84-`(`_editName`) | **미확인** | `showProfileTextSheet` await 후 `setState`에 `mounted` 체크 없음(`signup_step2_screen.dart:44`) — 시트가 모달이라 실사용 크래시 가능성은 낮으나 이론상 위반. → `PS-ACT-04` |
| Signup2 사진 | `signup_step2_screen.dart:47-49` | PASS(의도된 스텁) | "준비 중" 스낵바, 1단계에서 이미 확인된 의도된 미구현 — 결함 아님 |
| Signup2 교회 | `:51-63` | **미확인** | 동일 mounted 이슈(`:61`) → `PS-ACT-04` |
| Signup2 성별 | `:65-68` | **미확인** | 동일(`:67`) → `PS-ACT-04` |
| Signup2 연령대 | `:70-73` | **미확인** | 동일(`:72`) → `PS-ACT-04` |
| Signup2 다음 버튼 | `:75-92` | PASS | 이름 필수 검증(`:76-79`), 네트워크 호출 없음 |
| Signup3 라이트/다크 카드 | `signup_step3_screen.dart:160-179` | PASS | 탭 즉시 전역 미리보기 반영, 파괴적 아님, `dispose()`에서 원복(`:51-55`) |
| Signup3 시작 버튼 | `:190-215` | PASS | `_isLoading` dup-tap 방지(`:132,191`), 로딩 스피너(`:200-206`), 3종 catch(AuthException/PostgrestException/catch-all `:99-110`, PS-FLOW-01 수정 완료), `mounted` 체크(`:96,112`) |

## 홈(서신서)

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 글자크기 FAB | `home_screen.dart:46-55` | PASS | 바텀시트 오픈, 공통-B 해당(아이콘 전용, tooltip 없음) |
| "오늘" 링크 | `:78-94` | PASS | 단순 provider 갱신, 부작용 없음 |
| 빈 페이지 전체 탭 | `:237-263` | PASS | 작성 시트 오픈, 신규 draft 대상(B2) |
| 내용 있는 페이지 여백 탭 | `:272-288` | PASS | 항목 탭과 겹치지 않음(1단계 확인) |
| 기도 항목 탭 | `:472` | PASS | 수정 모드로 시트 오픈 |
| 기도 항목 길게 누르기(삭제) | `:474` | **FAIL(발견성)** | 삭제 진입점이 길게 누르기 유일 — 이미 `PS-FLOW-06`으로 등록됨(신규 아님, 재확인만) |

## 검색

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 검색 입력 | `history_search_overlay.dart:86-113` | PASS | `onChanged` 즉시 반영, 디바운스 없음(20건 제한이라 서버부하 미미, 문제 아님) |
| 결과 탭 | `:141-144` | PASS | 이동 후 컨트롤러 clear(`PS-FLOW-07`과 연결, 기존 등록됨) |

## 기도문 작성/수정

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 제목/본문 입력 | `prayer_write_screen.dart:370-416` | PASS | 신규모드 800ms 디바운스 draft 저장(B2), 수정모드는 미대상(`PS-FLOW-03` 기존 등록) |
| 닫기(X) | `:312-316` | PASS | 저장 중 `onPressed: null`, 공통-B 해당 |
| 글자크기 아이콘 | `:330-333` | PASS | 바텀시트, 공통-B 해당 |
| 저장/등록 버튼 | `:334-346` | PASS | `_canSave` disable조건 명세대로(`:293-300`), 저장 중 재탭 불가(버튼 자체가 로딩 스피너로 교체되는 패턴 확인) |
| 삭제 버튼(수정모드) | `:347-361` | PASS | 확인 다이얼로그 → 삭제 + Undo, 파괴적 액션 요건 충족 |
| Undo 스낵바 액션 | `:32-46` | PASS | 재insert 실패 시 별도 스낵바로 재알림 |

## 기도 기록 탭

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 달력 좌측 화살표 | `prayer_calendar.dart:111-120` | **FAIL(터치타겟)** | `constraints: const BoxConstraints()`(`:112`)로 `IconButton` 기본 48dp 최소값이 제거되고 `padding: EdgeInsets.zero` + `icon size:20`만 남아 실제 탭 영역이 20px 안팎 → 48×48dp 미달. → `PS-ACT-03` |
| 달력 우측 화살표 | `:123-146` | **FAIL(터치타겟, 동일)** | 위와 동일 패턴(`:130`) + disable조건은 정상(미래월 비활성 `:139`) → `PS-ACT-03`에 포함 |
| 달력 PageView 스와이프 | `:171-190` | PASS | 양방향 동기화 확인 |
| 날짜 셀 탭 | `:402-409` | PASS | 미래 날짜 `onTap:null` disable 정상 |
| 지난 기록 행 탭 | `recent_records_section.dart:93-95` | PASS | 단순 이동 |

## 커뮤니티

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| 모임 만들기 버튼 | `community_screen.dart:70-76` | PASS | 단순 push |
| 초대코드 버튼 | `:79-86` | PASS | 단순 push |
| 그룹 카드 탭 | `:108-111` | PASS | 단순 push |
| CreateGroup 아이콘 선택 | `create_group_screen.dart:121-163` | PASS | 풀피커, 부작용 없음 |
| CreateGroup 만들기 버튼 | `:173-235` | PASS(caveat) | `_loading` dup-tap 방지(`:20,213`), `mounted` 확인됨. 단 실패 시 `e.toString()` 원문 노출(`:47-51`) — 1단계에서 이미 "6단계 UX 후보"로 지적된 사항, 신규 결함 아님 |
| JoinGroup 코드입력+참여 버튼 | `join_group_screen.dart:92-141` | PASS(caveat) | `_loading` 가드(`:17,124`) 확인. 정원초과 시 서버 트리거 메시지 원문 노출 — 동일하게 기존 지적 유지, 신규 아님 |
| GroupDetail 상단 메뉴(☰) | `:132-143,287-360` | PASS | 권한별 분기 정상(방장/전원), 공통-B 해당 |
| GroupDetail + FAB | `:224-232,234-284` | PASS | 권한별 항목 노출 정상, 공통-B 해당 |
| GroupDetail 공지 삭제(X) | `:551-558` (핸들러 `:489`) | **✅ FAIL→수정완료(2026-07-25)** | `PS-ACT-01` — 편지삭제와 동일한 확인 다이얼로그(`showDialog<bool>`+취소/삭제하기) 추가, `deleteNotice` 호출 전에 `ok != true`면 조기 리턴하도록 수정. ARB 3키 신규, `flutter analyze` 신규 이슈 없음 |
| GroupDetail 공지 삭제(X) 터치타겟 | `:551-558` | **FAIL(터치타겟)** | `GestureDetector` + `Padding(left:8)` + `Icon(size:15)` — 버튼이 아니라 아이콘 자체 크기만큼만 반응, 48×48dp 대비 크게 미달 → `PS-ACT-02` |
| GroupDetail 편지 삭제(X) | `:677-684`(확인 `:598-625`) | PASS(터치타겟은 별도 FAIL) | 확인 다이얼로그 있음(공지와 달리 정상) — 단 터치타겟은 공지 삭제와 동일한 `GestureDetector`+`size:15` 패턴 → `PS-ACT-02`에 함께 포함 |
| "🙏 함께 기도" 칩 | `:794-828` | PASS | `_busy` 플래그로 dup-tap 방지 확인(`:716,719-726`), `mounted` 체크(`:725`) |
| 아바타 스택/칩 길게누르기·탭 | `:796,830` | PASS | 참여자 목록 시트, 부작용 없음 |
| 멤버 내보내기 | `:1029-1036,956-973` | PASS | 확인 다이얼로그 O, 방장 권한 검증 |
| InviteGroup 코드 탭(복사) | `invite_group_screen.dart:82-88` | PASS | 클립보드 복사 + 스낵바 피드백 |
| InviteGroup 공유 버튼 | `:117-135` | PASS | OS 공유시트 위임, 공통-B 해당 |
| NoticeWrite 등록 버튼 | `notice_write_screen.dart:65-70,93-105` | PASS | `_sending` dup-tap 방지 확인(`:19,66`) |
| CommunityLetterWrite 공개범위 칩 | `:208-231,102-162` | PASS | 단일 선택 정상 |
| CommunityLetterWrite 전송 버튼 | `:255-270,186-195` | PASS | `_sending` 가드 확인(`:32,194`) |

## 설정 전반

| 요소 | 파일:라인 | 판정 | 근거 |
|---|---|---|---|
| Settings 4개 그룹 타일 | `settings_screen.dart:48-94` | PASS | 각각 단순 push |
| ProfileEdit 필드 5종(이름/사진/교회/성별/연령대) | `profile_edit_screen.dart:43-82` | **미확인** | Signup2와 동일 위젯 공유, 동일하게 await 후 `mounted` 체크 없음(`:43-82` 각 헬퍼) → `PS-ACT-04`에 통합 |
| ProfileEdit 저장 버튼 | `:171-196` | PASS | `_isSaving` dup-tap 방지(`:26,172`). `on PostgrestException`만 catch — 네트워크 예외 무처리는 1단계에서 이미 "5단계 엣지케이스 후보"로 등록됨(신규 아님, 이번 단계 스코프는 아님) |
| AppSettings 알림 타일 | `app_settings_screen.dart:140-149` | PASS | 단순 push |
| AppSettings 테마/언어 타일 | `:156-167` | PASS | 즉시 반영, 확인버튼 없음 — 취소/되돌리기 불필요한 비파괴적 설정이라 FR 위반 아님 |
| NotificationSettings 알람 추가 버튼 | `notification_settings_screen.dart:128-148` | **미확인** | `_addAlarm`이 `showTimePicker`/`requestPermission` await 후 `context`/`ref` 계속 사용하는데 `context.mounted` 체크 없음(`:38-43`) → `PS-ACT-05` |
| NotificationSettings 알람 타일(시간탭) | `:154-219` | **미확인** | `_editTime`도 동일 패턴(`:46-53`) → `PS-ACT-05`에 통합 |
| NotificationSettings 알람 타일(삭제) | `:154-219` | PASS(caveat) | 확인 없이 즉시 삭제 — 항목 자체가 로컬설정(서버 데이터 아님)이라 파괴적 액션 심각도 낮음, 결함 승격 안 함 |
| NotificationSettings 알람 타일(토글) | `:154-219` | **미확인** | `if (v) await NotificationService.requestPermission();` 이후 처리 동일 패턴(`:116-117`) → `PS-ACT-05`에 통합 |
| Feedback 카테고리 칩 4종 | `feedback_screen.dart:129-140,220-256` | PASS | 단일 선택 |
| Feedback 전송 버튼 | `:177-202` | PASS | `_isSending` dup-tap 방지(`:40,178`) |
| Feedback "메일로 보내기" | `:204-214` | PASS | 로컬 앱 전환이라 dup-tap 위험 낮음, DB전송과 별개 경로인 점은 1단계에서 이미 지적(신규 아님) |
| Account 로그아웃 타일 | `account_screen.dart:126-133` | PASS | 확인 다이얼로그 → 순차 정리(`clearAll`→`signOut`→`popUntil`) |
| Account 회원탈퇴 타일 | `:136-144` | PASS | 확인 다이얼로그(destructive 스타일) → Edge Function → 로컬 정리 |

## 도달 불가 요소 (판정 제외)

| 요소 | 사유 |
|---|---|
| `GroupInfoScreen` 전체 | 1단계에서 고아 화면으로 확인됨 — push 경로 없음, 액션 검증 대상에서 제외 |
| `PrayForSomeoneScreen` 전체 | 동일 — 고아 화면 |

---

## 신규 결함 (이번 3단계에서 처음 발견 → `qa/04_defects.md`에 등록)

- **`PS-A11Y-01`** — 아이콘 온리 버튼 tooltip/Semantics 라벨 전무 (S4)
- **`PS-ACT-01`** — GroupDetail 공지 삭제, 파괴적 액션인데 확인 다이얼로그 없음 (S3)
- **`PS-ACT-02`** — GroupDetail 공지/편지 삭제(X) 버튼 터치타겟 48×48dp 미달 (S4)
- **`PS-ACT-03`** — 기록탭 달력 좌우 화살표 터치타겟 48×48dp 미달 (S4)
- **`PS-ACT-04`** — 프로필 필드 편집 헬퍼(Signup2/ProfileEdit 공통) await 후 mounted 체크 없음 (S4)
- **`PS-ACT-05`** — NotificationSettings 화면 await 후 context.mounted 체크 없음 (S4)

기존 결함(`PS-FLOW-03,06,07`, CreateGroup/JoinGroup 에러노출, ProfileEdit 네트워크예외 미처리)은 1단계에서 이미 등록됐거나 스코프컷 확정된 사안이라 재등록하지 않고 이번 단계에서 "재확인"만 표기함.

---

## 판정 집계표

| 판정 | 개수 | 내역 |
|---|---|---|
| PASS | 55 | (터치타겟 FAIL과 별개로 확인다이얼로그가 정상인 편지삭제 행 포함) |
| FAIL | 5 | 길게누르기 발견성(1, `PS-FLOW-06` 재확인) · 달력 좌/우 화살표 터치타겟(2, `PS-ACT-03`) · 공지삭제 확인없음(1, `PS-ACT-01`) · 공지·편지삭제 터치타겟(1행, `PS-ACT-02`) |
| 미확인 | 8 | Signup2 필드편집 3종 + ProfileEdit 필드편집(1행, 5종 통합) — mounted 체크 부재(`PS-ACT-04`) · NotificationSettings 알람추가/시간탭/토글(3, `PS-ACT-05`) |
| 판정 제외(도달불가) | 2 | `GroupInfoScreen`, `PrayForSomeoneScreen` — 고아 화면 |
| **총계** | **70** | |
