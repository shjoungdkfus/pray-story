# QA 결함 목록 (04_defects.md, 누적)

> `docs/CLAUDE.md` 결함 리포트 포맷 그대로. 2단계~6단계를 정식으로 거치지 않고 1단계+7단계만 진행한 세션에서 나온 결함이라 현재는 7단계(보안검증)에서 나온 것만 있음. 정식 순서대로 진행 시 여기에 계속 누적할 것.
>
> **★ 2026-07-25 — PS-SEC-01, PS-SEC-02 둘 다 수정 완료·재검증 PASS(11/11).** 수정 SQL은 `supabase_sql/rls_fixes_2.sql`(사용자가 Supabase 대시보드에서 직접 실행), 재검증은 신규 테스트계정 3개로 회귀 케이스(그룹편지 반응 유지, 전체공개 반응 유지, 본인 반응 유지, 비멤버/비로그인 차단 유지)까지 전부 확인 후 자가정리 완료. 아래 두 항목은 "outcome: fixed"로 갱신.

## PS-SEC-01

| 항목 | 내용 |
|---|---|
| ID | PS-SEC-01 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — `supabase_sql/rls_fixes_2.sql` 실행 후 재검증 PASS |
| 심각도 | S2 Critical |
| 관련 요구사항 | SPEC-GAP (그룹 멤버간 프로필 조회는 코드 구현 의도는 명확하나 SPEC.md에 FR로 명문화 안 됨) |
| 위치 | Supabase `profiles` 테이블 RLS 정책 — 의도된 정의는 `supabase_sql/community_v2.sql:70-78` |
| 현상 | 같은 그룹 멤버끼리도 서로의 `profiles` 행을 select로 조회할 수 없다 |
| 재현 절차 | 1. A가 그룹 생성 2. B가 그룹 참여(성공 확인) 3. B의 토큰으로 `GET /rest/v1/profiles?id=eq.{A}` → `[]` |
| 기대 결과 | `id = auth.uid() OR id IN (같은 그룹 멤버)`면 조회 허용(`community_v2.sql:70-78` 정의대로) |
| 실제 결과 | 0행 반환 — 정책 미적용과 동일 동작 |
| 근본 원인 | 파일엔 정책이 있으나 실제 프로젝트에 미적용되었거나 이후 마이그레이션에 덮어써진 것으로 추정(`pg_policies` 직접 조회로 확정 필요) |
| 수정 제안 | Supabase 대시보드 SQL Editor에서 `community_v2.sql:70-78` 블록만 재실행 후 재검증 |
| 회귀 위험 | 없음(조회 범위 확장 방향) |
| 검출 기법 | 상태전이 기반 오류 추정(그룹 참여 전/후 권한 전이) |
| 상세 | `qa/07_rls_security_audit.md` PS-SEC-01 참고 — 실서비스 영향(그룹/공지/중보 이름 전부 표시 안 될 가능성) 포함 |

## PS-SEC-02

| 항목 | 내용 |
|---|---|
| ID | PS-SEC-02 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — `supabase_sql/rls_fixes_2.sql` 실행 후 재검증 PASS(그룹편지/전체공개 반응 회귀 없음 확인) |
| 심각도 | S3 Major (실악용 경로 없음 — 아래 참고) |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `supabase_sql/community_v2.sql:54-66`(`letter_prayers` insert/select 정책) |
| 현상 | `letter_prayers`의 insert/select가 원본 편지(`community_letters`)의 visibility와 무관하게 동작 — private 편지의 id를 아는 사람은 누구나 반응 추가/조회 가능 |
| 재현 절차 | `qa/07_rls_security_audit.md` PS-SEC-02 참고 |
| 기대 결과(추정) | insert/select 모두 해당 letter를 볼 수 있는 사용자로 제한 |
| 실제 결과 | `USING(true)`/`auth.uid()=user_id`만 확인, letter 가시성 미확인 |
| 근본 원인 | 정책 설계 시 letter_id 참조 무결성만 확인하고 가시성 조건을 안 물려받음 |
| 수정 제안 | insert `WITH CHECK`/select `USING`에 community_letters 가시성 조건 추가 — 단 실사용 노출 경로가 없어 P2 백로그로도 무방(사용자 판단 대기) |
| 회귀 위험 | 낮음 |
| 검출 기법 | 오류 추정(간접 참조 무결성 미검증) |
| 상세 | `qa/07_rls_security_audit.md` PS-SEC-02 참고 |

---

## PS-FLOW-01

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-01 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-07-26)** — `signup_step3_screen.dart` catch-all 추가, `flutter analyze` 기존과 동일 23 info만(신규 이슈 없음). 갤럭시 S23에서 완전 오프라인(wifi+데이터 차단) 상태로 재현 → "가입 중 문제가 발생했어요..." 스낵바 정상 노출 확인 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-006(회원가입) 관련, 명시적 에러처리 요구는 SPEC-GAP |
| 위치 | `lib/screens/auth/signup_step3_screen.dart:65-109`(`_finish()`) |
| 현상 | `on AuthException`/`on PostgrestException`만 catch, 네트워크 예외 등 그 외 예외는 무처리 |
| 재현 절차 | 1. 회원가입 3단계까지 진행 2. 오프라인 상태로 전환 3. "시작하기" 탭 |
| 기대 결과 | 실패 원인을 사용자에게 안내(스낵바 등) |
| 실제 결과 | `finally`로 로딩만 풀리고 아무 메시지 없이 종료 — 원인 불명 상태로 남음 |
| 근본 원인 | catch 절이 두 타입으로 한정, catch-all 없음 |
| 수정 제안 | 마지막에 `catch (e) { _snack(l.errSignupFailed); }` 추가 |
| 회귀 위험 | 없음 |
| 검출 기법 | 오류 추정(네트워크 예외 케이스) |

## PS-FLOW-02

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-02 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-07-26)** — 공용 `OnboardingExitGuard`(`auth/widgets/profile_form.dart`) 신설, Signup2/3 양쪽에 적용. ARB 3키 추가(`onboardingExitTitle/Message/Confirm`), `flutter analyze` 신규 이슈 없음. 갤럭시 S23에서 Google 신규계정 온보딩 진입 → 시스템 뒤로가기 → 확인다이얼로그 노출, 취소(화면유지)·종료(실제 앱종료, `mCurrentFocus`=런처 확인) 둘 다 정상 동작 확인 |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/main.dart:118-121`(OAuth 온보딩 분기), `lib/screens/auth/signup_step2_screen.dart`, `signup_step3_screen.dart`(둘 다 `PopScope` 없음) |
| 현상 | 카카오/구글 첫 로그인 온보딩 경로에서 `SignupStep2Screen`이 `_RootGate`가 직접 반환하는 라우트 스택의 루트가 됨 — 이 상태에서 시스템 뒤로가기 시 확인 없이 앱이 그대로 종료됨 |
| 재현 절차 | 1. 카카오/구글로 첫 로그인(신규 계정) 2. 프로필 입력 화면에서 시스템 뒤로가기(제스처/버튼) |
| 기대 결과 | 확인 다이얼로그 또는 최소한 뒤로가기 무시 |
| 실제 결과 | 앱 즉시 종료(데이터 유실은 없음 — 재실행 시 같은 온보딩 화면 재진입) |
| 근본 원인 | `MainShell`에만 `PopScope`(`main.dart:171`)가 있고 온보딩 화면들엔 없음 |
| 수정 제안 | Signup2/3에 온보딩 경로(email/password null)일 때만 적용되는 `PopScope` 추가 |
| 회귀 위험 | 낮음 |
| 검출 기법 | 상태전이(불법 전이 탐색 — 뒤로가기) |

## PS-FLOW-03

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-03 |
| 심각도 | S3 Major (기존 스코프컷 재확인, 신규 결함 아님) |
| 관련 요구사항 | FR-005 (적용범위가 수정모드까지인지 SPEC-GAP) |
| 위치 | `lib/screens/write/prayer_write_screen.dart:107-108,130` |
| 현상 | 신규작성만 draft 자동저장 대상, 수정모드는 이탈 시 편집 중이던 내용이 보존 안 됨(원본은 유지) |
| 재현 절차 | 1. 기존 기도문 수정 화면 진입 2. 내용 변경 3. 저장 전 강제종료/뒤로가기 |
| 기대 결과 | SPEC.md FR-005 확정 필요 — 수정모드도 보호 대상인지 |
| 실제 결과 | 수정분 유실, 원본 유지 |
| 근본 원인 | `_isNewMode`(`prayer==null`)만 draft 저장 대상으로 설계(2026-07-24 세션 의도적 결정) |
| 수정 제안 | 필요 시 수정모드 전용 draft 키 추가해 확장 가능 — 우선 사용자 판단(P1) |
| 회귀 위험 | — |
| 검출 기법 | 상태전이(F4/F11 이탈 시나리오) |

## PS-FLOW-04

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-04 |
| 심각도 | S2/S3(발생빈도 낮음, 실증 안 함) |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/main.dart:105-127`(`_RootGate.build()`) |
| 현상 | 세션 만료로 인증상태가 바뀌면 `_RootGate`가 반환하는 서브트리 전체가 교체되며, 그 안에서 열려있던 기도문 작성 바텀시트(모달 라우트)도 함께 강제로 닫힘 |
| 재현 절차 | (구조 분석, 실제 세션만료 재현 안 함) 1. 기도문 작성 중 2. 세션 만료(리프레시토큰 무효화) 3. authState가 signedOut으로 전환 |
| 기대 결과 | 최소한 경고 또는 작성중 내용 보존 |
| 실제 결과 | 신규모드는 draft(B2)가 일부 방어, 수정모드는 무방비 |
| 근본 원인 | `_RootGate`가 인증상태별로 완전히 다른 위젯 서브트리를 반환하는 구조 — 그 안의 모달까지 함께 사라짐 |
| 수정 제안 | 낮은 발생빈도 대비 구조 변경 비용이 크므로 우선순위 낮음 — 백로그 후보 |
| 회귀 위험 | — |
| 검출 기법 | 상태전이 + 오류추정(세션만료는 QA프롬프트 F7 표준 시나리오) |

## PS-FLOW-05

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-05 |
| 심각도 | S4 Minor |
| 관련 요구사항 | FR-010(테마) 등 — SPEC엔 콜드스타트 렌더링 타이밍 요구사항 없음 |
| 위치 | `lib/providers/settings_provider.dart:20,69`, `lib/providers/notification_provider.dart:10` |
| 현상 | `themeModeProvider`/`languageProvider`/`prayerAlarmsProvider` 셋 다 동기 기본값으로 먼저 렌더된 뒤 비동기 `SharedPreferences` 로드 완료 시 실제값으로 교체 — 콜드스타트 첫 프레임에 잘못된 값이 잠깐 보일 수 있음 |
| 재현 절차 | 다크모드 저장된 상태에서 콜드스타트 후 첫 프레임 관찰(육안 확인 필요, 프레임 단위라 체감 미미할 수 있음) |
| 기대 결과 | 저장된 값 로드 전까지 로딩 상태 표시 또는 스플래시 유지 |
| 실제 결과 | 기본값(라이트/기기감지언어/빈알람) 잠깐 노출 |
| 근본 원인 | Provider 생성자 패턴("동기 기본값 + 비동기 _load()") 3곳 공통 |
| 수정 제안 | 우선순위 낮음, 체감 여부 실기기 확인 후 필요시 개선 |
| 회귀 위험 | — |
| 검출 기법 | 상태전이(F12 재시작 후 유지) |

## PS-FLOW-06

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-06 |
| 심각도 | S4 Minor (1단계에서 이미 지적한 것 재확인) |
| 관련 요구사항 | FR-004 |
| 위치 | `lib/screens/home/home_screen.dart:474` |
| 현상 | 홈 화면에서 기도문 삭제 진입점이 길게 누르기 하나뿐, 시각적 힌트 없음 |
| 재현 절차 | 홈 화면에서 기도 항목을 어떻게 지우는지 시각적으로 찾아보기 |
| 기대 결과 | 스와이프 삭제 또는 아이콘 등 발견 가능한 UI |
| 실제 결과 | 길게 눌러야만 삭제 다이얼로그 등장 |
| 근본 원인 | 삭제 액션이 `onLongPress`에만 연결 |
| 수정 제안 | 우선순위 낮음, 필요시 스와이프 액션 추가 |
| 회귀 위험 | — |
| 검출 기법 | 탐색적(발견성 점검) |

## PS-FLOW-07

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-07 |
| 심각도 | S4 Minor (의도된 설계로 추정) |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/home/history_search_overlay.dart:52-61` |
| 현상 | 검색 결과 선택 시 검색창/결과가 초기화됨 — 기록 탭 복귀 시 방금 검색 내용이 안 보임 |
| 재현 절차 | 기록 탭 검색 → 결과 탭 → 서신서로 이동 → 기록 탭 복귀 |
| 기대 결과 | (SPEC 미정) |
| 실제 결과 | 검색창 비어있음 |
| 근본 원인 | `_selectPrayer()`가 명시적으로 컨트롤러 clear |
| 수정 제안 | 의도된 동작일 가능성 높음 — 사용자 확인만 필요, 코드 수정 불필요할 수도 |
| 회귀 위험 | — |
| 검출 기법 | 상태전이(F6 되돌아가기 오염 패턴) |

---

## PS-A11Y-01

| 항목 | 내용 |
|---|---|
| ID | PS-A11Y-01 |
| 상태 | **◑ 부분 수정 (2026-07-28)** — 뒤로가기 아이콘 버튼(앱 전체 14곳, `IconButton`의 절반)에 `tooltip: l.commonBack` 추가(ARB 신규 `commonBack` ko/en). **나머지 14곳(비밀번호 표시, 삭제/X, 달력 이동, 글자크기, 편집, 공유, 추가, 햄버거 메뉴 등)은 의도적으로 백로그 유지** — 사용자 판단: "문제 안 생기고 잘 해결되는 것만" 우선 처리. `flutter analyze` 기존과 동일 23 info만(신규 이슈 0). |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP(접근성 요구사항 명문화 없음) |
| 위치 | 앱 전체 아이콘 온리 버튼(`Grep tooltip:` 0건, `Grep Semantics\(` 0건) |
| 현상 | 아이콘만 있는 버튼(뒤로가기, 글자크기, 메뉴☰, +FAB, 공유 등)에 `tooltip`/`Semantics` 라벨이 전혀 없음 |
| 재현 절차 | TalkBack/VoiceOver로 각 화면 순회 — 아이콘 버튼에서 읽어주는 설명 없음 |
| 기대 결과 | 아이콘 버튼에 최소 `tooltip:` 또는 `Semantics(label:)` |
| 실제 결과 | 스크린리더 사용자에게 버튼 기능이 전달되지 않음 |
| 근본 원인 | 디자인/구현 단계에서 접근성 라벨을 관례로 넣지 않음(전 화면 공통 패턴) |
| 수정 제안 | 우선순위 낮음 — 접근성 개선 백로그로 일괄 처리 권장(개별 수정보다 공통 위젯화 후 일괄 적용이 효율적) |
| 회귀 위험 | 없음(라벨 추가만) |
| 검출 기법 | 정적 분석(전수 grep) — 3단계 액션검증 |

## PS-ACT-01

| 항목 | 내용 |
|---|---|
| ID | PS-ACT-01 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — 편지삭제와 동일한 확인 다이얼로그 추가, ARB 3키 신규(`noticeDeleteTitle/Confirm/Button`), `flutter analyze` 기존과 동일 23 info만(신규 이슈 없음) |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/community/group_detail_screen.dart:551-558`(버튼), 핸들러 `:489` 부근 |
| 현상 | 방장이 공지 삭제(X) 탭 시 확인 다이얼로그 없이 즉시 삭제됨 — 같은 화면의 편지 삭제(`:677-684`)는 확인 다이얼로그(`:598-625`)가 있어 동일 화면 내 파괴적 액션 처리가 불일치 |
| 재현 절차 | 1. 방장 계정으로 그룹 상세 진입 2. 공지 카드의 X 아이콘 탭 |
| 기대 결과 | 삭제 전 확인 다이얼로그(편지 삭제와 동일 패턴) |
| 실제 결과 | 탭 즉시 `deleteNotice` 실행 + `invalidate` — 되돌릴 방법 없음(Undo 없음) |
| 근본 원인 | 공지 삭제 UI를 구현할 때 편지 삭제에 이미 있던 확인 다이얼로그 패턴을 재사용하지 않음 |
| 수정 제안 | 편지 삭제와 동일한 확인 다이얼로그를 공지 삭제에도 적용 |
| 회귀 위험 | 없음 |
| 검출 기법 | 액션 체크리스트(파괴적 액션 확인 여부) — 3단계 |

## PS-ACT-02

| 항목 | 내용 |
|---|---|
| ID | PS-ACT-02 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — 두 삭제 버튼 모두 `GestureDetector`→`IconButton`(`constraints: BoxConstraints(minWidth:48,minHeight:48)`)로 교체, 시각적 변화 없음. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP(터치타겟 크기 요구사항 없음, Material 접근성 가이드 기준) |
| 위치 | `lib/screens/community/group_detail_screen.dart:551-558`(공지 삭제), `:677-684`(편지 삭제) |
| 현상 | 두 삭제 버튼 모두 `GestureDetector` + `Padding(left:8)` + `Icon(size:15)` 구조 — `IconButton` 기본 48dp 최소 탭 영역이 전혀 적용되지 않음, 실제 반응 영역이 아이콘 크기(15px)+패딩(8px) 수준 |
| 재현 절차 | 실기기에서 아이콘 가장자리를 살짝 벗어나 탭 → 반응 안 함 |
| 기대 결과 | 최소 48×48dp 탭 영역(예: `IconButton`으로 교체하거나 `SizedBox(width:48,height:48)`로 감싸기) |
| 실제 결과 | 작은 화면/큰 손가락 사용자에게 오탭 실패 빈발 가능 |
| 근본 원인 | 커스텀 `GestureDetector` 사용 시 터치타겟 확장 없이 아이콘만 감쌈 |
| 수정 제안 | `IconButton(icon:.., iconSize:15, onPressed:..)`으로 교체(기본 48dp 유지하며 아이콘 크기만 작게 유지 가능) |
| 회귀 위험 | 낮음(탭 영역만 확장, 시각적 변화 없음) |
| 검출 기법 | 액션 체크리스트(터치타겟 ≥48dp) — 3단계 |

## PS-ACT-03

| 항목 | 내용 |
|---|---|
| ID | PS-ACT-03 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — 좌/우 화살표 둘 다 `constraints: BoxConstraints(minWidth:48,minHeight:48)`로 교체(기존 `BoxConstraints()` 무제한 축소 제거). `flutter analyze` 신규 이슈 없음 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/record/widgets/prayer_calendar.dart:111-120,123-146` |
| 현상 | 달력 좌/우 월 이동 화살표가 `IconButton`에 `constraints: const BoxConstraints()`를 명시해 기본 48dp 최소 탭 영역을 제거함 — `padding: EdgeInsets.zero` + `icon size:20`만 남아 실제 탭 영역이 20px 안팎 |
| 재현 절차 | 실기기에서 화살표 아이콘 가장자리 밖을 탭 → 반응 안 함 |
| 기대 결과 | 최소 48×48dp 유지(`constraints` 오버라이드 제거 또는 `BoxConstraints(minWidth:48,minHeight:48)`로 교체) |
| 실제 결과 | 좁은 탭 영역으로 오탭 실패 가능 |
| 근본 원인 | 헤더 레이아웃을 좁게 맞추려고 `constraints`를 명시적으로 축소 |
| 수정 제안 | `constraints` 제거하거나 최소값 48로 지정, 필요시 헤더 레이아웃 여백 조정 |
| 회귀 위험 | 낮음(레이아웃 폭이 약간 넓어질 수 있어 헤더 정렬 재확인 필요) |
| 검출 기법 | 액션 체크리스트(터치타겟 ≥48dp) — 3단계 |

## PS-ACT-04

| 항목 | 내용 |
|---|---|
| ID | PS-ACT-04 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — Signup2/ProfileEdit 8개 헬퍼(양쪽 4개씩) 전부 `await` 직후 `if (!mounted) return;` 가드 추가. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/auth/signup_step2_screen.dart:35-73`(`_editName/_editChurch/_editGender/_editAge`), `lib/screens/settings/profile_edit_screen.dart:43-82`(동일 헬퍼 4종) |
| 현상 | 프로필 필드 편집 바텀시트/피커를 `await`한 뒤 결과로 `setState`를 호출하는데 `mounted` 체크가 없음 |
| 재현 절차 | (이론적) 바텀시트가 열려 있는 동안 위젯이 dispose되는 경합 상황 — 일반 사용 흐름에서는 모달이 내비게이션을 막아 발생 빈도 매우 낮음 |
| 기대 결과 | `if (!mounted) return;` 가드 후 `setState` |
| 실제 결과 | 이론상 dispose된 State에 `setState` 호출 시 예외 발생 가능(디버그 모드 assertion) |
| 근본 원인 | Signup2/ProfileEdit이 같은 프로필 편집 헬퍼 패턴을 공유하면서 둘 다 `mounted` 가드를 빠뜨림 |
| 수정 제안 | 4개 헬퍼 전부에 `mounted` 체크 추가(두 파일 공통 패턴이라 한 번에 일괄 수정 가능) |
| 회귀 위험 | 없음 |
| 검출 기법 | 액션 체크리스트(await 이후 mounted 체크) — 3단계 |

## PS-ACT-05

| 항목 | 내용 |
|---|---|
| ID | PS-ACT-05 |
| 상태 | **✅ 수정 완료 (2026-07-25)** — `_addAlarm`/`_editTime`/토글 핸들러 3곳 전부 `await` 직후 `if (!context.mounted) return;` 가드 추가. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/settings/notification_settings_screen.dart:38-53`(`_addAlarm`,`_editTime`), `:114-119`(토글 핸들러) |
| 현상 | `showTimePicker`/`NotificationService.requestPermission()` 등 `await` 이후 `context`/`ref`를 계속 사용하는데 `context.mounted` 체크가 없음(이 화면은 `ConsumerWidget`이라 `State.mounted`가 아니라 `context.mounted`를 써야 함) |
| 재현 절차 | (이론적) 타임피커/권한요청 대화상자가 떠 있는 동안 화면이 pop되는 경합 상황 |
| 기대 결과 | `await` 직후 `if (!context.mounted) return;` |
| 실제 결과 | 이론상 비활성 컨텍스트 참조 예외 가능성 |
| 근본 원인 | `ConsumerWidget` 기반 화면이라 `mounted` 프로퍼티가 기본 제공되지 않는데 대체 체크(`context.mounted`)도 누락 |
| 수정 제안 | 두 함수 모두 `await` 직후 `context.mounted` 가드 추가 |
| 회귀 위험 | 없음 |
| 검출 기법 | 액션 체크리스트(await 이후 mounted 체크) — 3단계 |

---

## PS-CRUD-01

| 항목 | 내용 |
|---|---|
| ID | PS-CRUD-01 |
| 상태 | **✅ 수정 완료 (2026-07-26)** — 검색어를 큰따옴표로 감싸고 `\`·`"`만 이스케이프해 리터럴로 처리. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-009(검색) |
| 위치 | `lib/providers/prayer_provider.dart:83-100`(`searchResultsProvider`) |
| 현상 | 검색어를 이스케이프 없이 `.or('title.ilike.%$query%,content.ilike.%$query%')` 문자열에 직접 삽입. PostgREST의 `or()`는 콤마·괄호를 조건 구분자로 파싱하므로 검색어에 `,` `(` `)`가 포함되면 로직트리 파싱이 깨짐 |
| 재현 절차 | 1. 실제 Supabase REST로 재현(디스포저블 테스트계정+prayers 2건 insert) 2. 앱이 보내는 것과 동일한 `or=(title.ilike.%,%,content.ilike.%,%)` 쿼리 실행 |
| 기대 결과 | 검색어에 특수문자가 있어도 정상 검색되거나, 최소한 사용자에게 실패를 알림 |
| 실제 결과 | 서버가 **400 Bad Request**(`PGRST100`, "failed to parse logic tree") 반환. UI(`history_search_overlay.dart:125-129`)는 `results.maybeWhen(orElse: () => _lastResults)`로 에러 상태를 조용히 이전 결과/빈 화면으로 덮어써 **사용자에게 아무 안내 없이 검색이 그냥 안 되는 것처럼 보임** |
| 근본 원인 | PostgREST `or()` 필터는 값이 아닌 전체 문자열을 로직트리로 파싱 — 사용자 입력을 이스케이프 없이 삽입하면 구조가 깨짐 |
| 수정 제안 | 값을 큰따옴표로 감싸고 내부의 `\`·`"`만 이스케이프(`title.ilike."%$escaped%"`) — PostgREST 로직트리 값 이스케이프 표준 방식. 실제 수정: `escaped = query.replaceAll(r'\', r'\\').replaceAll('"', r'\"')` 후 `'title.ilike."%$escaped%",content.ilike."%$escaped%"'` |
| 회귀 위험 | 낮음(정상 검색어는 큰따옴표로 감싸도 ilike 패턴 매칭 동일하게 동작 — curl로 정상케이스·콤마·괄호·따옴표 4종 재검증 완료, 전부 200) |
| 검출 기법 | 오류 추정 + 동등분할(TC-EQ-042/TC-ERR-12, QA 4단계) — Supabase REST 직접 호출로 재현·수정 검증 |

---

## PS-CRUD-02

| 항목 | 내용 |
|---|---|
| ID | PS-CRUD-02 |
| 상태 | **✅ 수정 완료 (2026-07-26)** — `.select()`로 실제 반영행 확인, 0건이면 `errPrayerNotFound` 스낵바로 안내 후 화면 닫음. ARB 2키 추가(ko/en), `flutter analyze` 신규 이슈 없음 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-003(수정) |
| 위치 | `lib/screens/write/prayer_write_screen.dart:188-193`(수정 전) |
| 현상 | `.update({...}).eq('id', widget.prayer!.id)`에 `.select()`가 없어 0행이 매칭돼도(대상이 타 기기·세션에서 이미 삭제된 경우) PostgREST가 에러를 던지지 않음 |
| 재현 절차 | 1. 기도문 상세를 열어둔 채(캐시된 `prayer` 객체 보유) 2. 같은 계정의 다른 세션/기기에서 그 기도문을 삭제 3. 원래 화면에서 내용 수정 후 저장 |
| 기대 결과 | 대상이 더 이상 없음을 사용자에게 알리고 목록을 갱신 |
| 실제 결과 | 아무 행도 갱신되지 않았는데 `l.writeUpdated`("수정되었습니다") 성공 스낵바가 그대로 뜸 — 사용자는 저장된 줄 알지만 실제로는 아무 것도 반영 안 됨 |
| 근본 원인 | Supabase `update()`는 기본적으로 `Prefer: return=minimal`이라 매칭 행 수와 무관하게 204를 반환, 반영행 수를 확인하지 않으면 0건 매칭도 성공처럼 보임 |
| 수정 제안 | `.update({...}).eq('id', ...).select()`로 바꿔 반환된 리스트가 비었으면 별도 안내(`errPrayerNotFound`) 후 화면 닫고 목록 invalidate |
| 회귀 위험 | 낮음(정상 케이스는 `.select()` 추가해도 응답 형태만 늘어날 뿐 기존 update 동작과 동일) |
| 검출 기법 | 상태전이(불법 전이 — 삭제됨 상태에 대한 수정 시도, TC-ST-025/TC-ERR-14, QA 4단계) |

---

## PS-CRUD-03

| 항목 | 내용 |
|---|---|
| ID | PS-CRUD-03 |
| 상태 | **✅ 수정 완료 (2026-07-26)** — `_save()` 함수 진입 시점에 `_isSaving` 재확인 추가. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S4 Minor |
| 관련 요구사항 | FR-001(저장) |
| 위치 | `lib/screens/write/prayer_write_screen.dart:176-179`(수정 전) |
| 현상 | 저장 버튼의 `onPressed: _isSaving \|\| !_canSave ? null : _save`는 **다음 build에서만** 비활성화가 반영되는데, `_save()` 함수 자체는 `_canSave`만 재확인하고 `_isSaving`은 확인하지 않음 |
| 재현 절차 | (이론적) 매우 빠른 연속 탭으로 `setState` rebuild가 반영되기 전에 두 번째 `onPressed` 호출이 들어가는 경합 상황 — 실기기에서 결정적으로 재현하긴 어려움(타이밍 의존) |
| 기대 결과 | 두 번째 호출은 함수 진입 시점에 즉시 무시됨 |
| 실제 결과 | 버튼 비활성화가 위젯 rebuild 타이밍에 의존하는 유일한 방어선이라, 이론상 중복 insert 가능성 존재 |
| 근본 원인 | 재진입 방지 가드가 UI 레이어(버튼 disabled)에만 있고 로직 레이어(함수 자체)엔 없음 |
| 수정 제안 | `if (_isSaving \|\| !_canSave) return;`으로 변경 — 버튼 상태와 무관하게 결정적으로 막음 |
| 회귀 위험 | 없음 |
| 검출 기법 | 액션 체크리스트("중복 탭 방지") 재검토 — QA 4단계 TC-ERR-01 |

---

## PS-CRUD-04

| 항목 | 내용 |
|---|---|
| ID | PS-CRUD-04 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-07-26)** — `searchResultsProvider`의 `loading`/`data`/`error` 상태를 명시적으로 분기, `_lastResults`는 loading 중 깜빡임 방지용으로만 사용. 에러 시 `searchError` 안내문구 노출. ARB 2키 추가(ko/en), `flutter analyze` 신규 이슈 없음 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-009(검색) |
| 위치 | `lib/screens/home/history_search_overlay.dart:65-80,116-130`(수정 전) |
| 현상 | `searchResultsProvider`에 try/catch가 없어 오프라인 시 `AsyncError` 상태가 되는데, `_buildResultsList()`가 `results.maybeWhen(data: (list) => list.isNotEmpty ? list : _lastResults, orElse: () => _lastResults)`로 **에러도, 진짜 빈 결과도 전부 이전 결과(stale)로 덮어씀** |
| 재현 절차 | 1. 갤럭시 S23 실기기, 테스트계정으로 로그인 후 기록탭 검색창에서 "gratitude" 검색 → 매칭 확인 2. `svc wifi disable`+`svc data disable`로 완전 오프라인 전환 3. 검색어를 "gratitude!"로 변경(기존 지우지 않고 이어서 입력) |
| 기대 결과 | 새 검색이 실패했음을 사용자에게 알림 |
| 실제 결과 | (수정 전) 이전 검색어("gratitude")의 매칭 결과("Morning gratitude")가 새 검색어("gratitude!")에 대한 결과인 것처럼 그대로 남아있음 — 사용자는 검색이 여전히 되는 줄 오인 |
| 근본 원인 | `maybeWhen`의 `orElse`가 `loading`과 `error`를 구분하지 않고 전부 `_lastResults`로 뭉뚱그림 |
| 수정 제안 | `results.when(loading: () => _buildList(_lastResults), data: _buildList, error: (_, _) => _buildSearchError(context))`로 명시적 3분기. `data`는 빈 리스트도 그대로 신뢰(더 이상 `_lastResults`로 대체 안 함), `ref.listen`도 빈 리스트를 포함해 항상 `_lastResults` 갱신하도록 변경 |
| 회귀 위험 | 낮음(정상 검색·빈결과 케이스 실기기 재검증 완료 — 온라인 복귀 후 재검색 정상 동작 확인) |
| 검출 기법 | QA 5단계 네트워크 조건 분석 → 실기기 재현(오프라인 전환) → 수정 → 재검증까지 완료 |

---

## PS-UI-01

| 항목 | 내용 |
|---|---|
| ID | PS-UI-01 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-07-26)** — `MaterialApp.builder`에서 `MediaQuery`의 `textScaler`를 `clamp(maxScaleFactor: 1.0)`로 확대만 제한. `flutter analyze` 신규 이슈 없음 |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC 9장 접근성 인접 항목이나 폰트배율 자체는 SPEC에 없어 SPEC-GAP였음 |
| 위치 | `lib/main.dart`(수정 전엔 `textScaler` 제어 코드 자체가 없었음) |
| 현상 | OS 접근성 폰트배율이 앱 자체 폰트크기 설정과 무관하게 전역 텍스트에 그대로 곱연산 적용됨 |
| 재현 절차 | 1. 갤럭시 S23에서 `adb shell settings put system font_scale 2.0`(또는 기기 설정에서 폰트 크기 최대) 2. 앱 재실행(런타임 반영도 즉시 되지만 콜드스타트로 확인) 3. 기록탭(달력) 화면 확인 |
| 기대 결과 | 최소한 핵심 화면의 레이아웃이 깨지지 않아야 함 |
| 실제 결과 | **200% 배율에서 달력 날짜 그리드가 통째로 화면 밖으로 밀려 안 보임**(1일 이후 숫자 전부 미표시), 지난기록 제목/본문이 심하게 잘림(ellipsis). **130%에서도 달력 마지막 줄이 잘림** — 낮은 배율에서도 이미 깨짐 확인 |
| 근본 원인 | `lib/` 전체에 `textScaler` 제어 코드가 0건(전수 grep 확인) + 달력 위젯(`prayer_calendar.dart`)의 그리드 높이 계산이 헤더 영역 실제 렌더 높이(텍스트 배율에 따라 가변)를 고려하지 않고 고정 가정 |
| 수정 제안 | 근본적으로 모든 화면을 가변 텍스트 높이에 대응시키는 대신, `MaterialApp.builder`에서 `MediaQuery`를 오버라이드해 확대 방향만 1.0으로 클램프(축소는 그대로 허용) — 앱이 자체 폰트크기 설정(11/15/25pt)을 이미 제공하므로 본문 확대 접근성은 별도 경로로 충족됨 |
| 회귀 위험 | 낮음(200% 재검증 시 달력 1~31일 전부 정상 표시, 홈 화면도 정상 크기로 렌더링 확인. 기존 0.8배율 사용성엔 영향 없음 — 축소는 클램프 대상 아님) |
| 검출 기법 | QA 5단계 디바이스 조건 분석(코드 전수 grep) → 실기기 재현(font_scale 2.0/1.3) → 수정 → 재검증까지 완료 |

---

# QA 6단계(UI/UX 심사) 신규 결함 — PS-UI-02 ~ PS-UI-18

> 2026-07-26, `qa/06_uiux_audit.md` 참고. **전부 정적 코드 리뷰 기반이며 실기기 조작은 하지 않았다**(사용자 지시로 1단계=정적만 수행).
> 대비비는 WCAG 2.1 공식으로 계산한 확정 수치이나, 체감 심각도·TalkBack 동작은 미확인(`06_uiux_audit.md` §11 목록).
> **S1 0건 / S2 0건 / S3 10건 / S4 7건 — 출시 차단 요소는 없음.**

## PS-UI-02

| 항목 | 내용 |
|---|---|
| ID | PS-UI-02 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — accent를 채움용(accent)/전경용(accentText) 두 토큰으로 분리, 전경 76곳 치환. 다크 전경 7.12~9.63:1 확보. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major (영향 범위는 앱 전역 — 6단계 최우선 권고) |
| 관련 요구사항 | FR-010(다크모드), SPEC 9장 "접근성: 대비 ≥4.5:1" |
| 위치 | 근본: `lib/core/constants/app_colors.dart:21`. 발현: `AppColors.accent` 전경 사용 전 지점(총 103회 참조) |
| 현상 | 다크 모드에서 `accent`를 글자·아이콘·테두리로 쓰는 모든 지점이 WCAG AA 미달(1.84~2.48:1) |
| 재현 절차 | 1. 설정→앱설정→테마→다크 선택 2. 커뮤니티→모임 상세→우상단 메뉴의 "저장"/"모임 나가기" 텍스트 버튼 확인 3. 로그인 화면 입력칸 포커스 시 테두리 확인 4. 기록탭 달력의 "오늘" 원 테두리 확인 5. 설정→앱설정→테마 시트에서 현재 선택 체크 아이콘 확인 |
| 기대 결과 | 일반 텍스트 4.5:1, UI 컴포넌트 3:1 이상 |
| 실제 결과 | accent `#4D4D4D` 기준 — background `#000000` 대비 **2.48:1**, card `#242424` 대비 **1.84:1**, bottomBar `#121212` 대비 **2.22:1**. 전부 미달 |
| 근본 원인 | `app_colors.dart:21` `static Color get accent => const Color(0xFF4D4D4D);` — 라이트·다크 **동일 고정**. 같은 파일에서 `calendarMark`(`:23`)와 `settingsIcon`(`:25`)은 "다크에선 밝게"라는 이유로 이미 분기해 뒀는데 **`accent`만 분기가 빠졌다.** 파생 문제로 `prayer_write_screen.dart:245`는 스낵바 배경만 accent로 덮고 글자색은 테마값(`main.dart:61` 다크에서 `#000000`)이라 2.48:1 |
| 수정 제안 | `static Color get accent => _isDark ? const Color(0xFFB5AFA3) : const Color(0xFF4D4D4D);` (calendarMark와 동일 톤 채택 시 다크 card 대비 7.12:1 확보). 단 **accent를 배경으로 쓰고 그 위에 흰 글씨를 얹는 지점**(`login_screen.dart:258-259`, `signup_step3_screen.dart:193-194`, `community_screen.dart:140,148,155`, `settings_kit.dart:252-258`, `notice_write_screen.dart:82`, `group_detail_screen.dart:570-573`)은 전경/배경이 뒤집히므로 **밝은 accent 위 흰 글씨는 1.5:1로 오히려 악화된다.** → `accentOn`(배경용) / `accent`(전경용) 두 토큰으로 분리하거나, 배경용 지점만 `fabColor` 계열 고정색으로 남기는 방식 권장 |
| 회귀 위험 | **높음(103개 참조 지점).** 전경용/배경용 용도가 한 토큰에 섞여 있어 일괄 치환 시 배경 사용처가 깨진다. 토큰 분리 후 라이트·다크 양쪽 전 화면 스크린샷 재검증 필요 |
| 검출 기법 | 6단계 다크모드 심사 — 팔레트 전수 대비비 계산 + `accent` 참조 전수 조사 |
| 상세 | `qa/06_uiux_audit.md` §0, §6 |

## PS-UI-03

| 항목 | 내용 |
|---|---|
| ID | PS-UI-03 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 홈 loading=스피너, error=ErrorRetryView(재시도)로 교체. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-001/FR-002 (SCR-05 홈), 6단계 요구 "4상태가 모든 화면에 존재" |
| 위치 | `lib/screens/home/home_screen.dart:231-233` |
| 현상 | 앱의 대표 화면인 홈(서신서)에 Loading·Error 상태가 없어 둘 다 **완전한 빈 화면**으로 표시된다 |
| 재현 절차 | (Loading) 1. 느린 네트워크에서 앱 진입 → 책 페이지 영역이 아무것도 없이 비어 있음 / (Error) 1. 서버 오류(`PostgrestException`) 유발 2. 홈 진입 → 안내문·재시도 없이 빈 카드만 표시 |
| 기대 결과 | Loading은 진행 표시, Error는 원인 안내 + 재시도 수단 |
| 실제 결과 | `loading: () => const SizedBox.shrink()`, `error: (_, _) => const SizedBox.shrink()` — 에러 시엔 빈 상태의 안내문(`homeEmptyToday`)과 "탭하면 작성" GestureDetector까지 사라져 **완전히 반응 없는 카드**가 된다 |
| 근본 원인 | `_BookPage.build`의 `prayers.when`이 data 외 두 분기를 의도적으로 무시. B3(오프라인 캐시) 도입으로 네트워크 예외는 캐시 폴백되지만 **서버 오류(`PostgrestException`)는 폴백 대상이 아니라** 이 빈 화면으로 떨어진다 |
| 수정 제안 | `loading:`은 기존 레이아웃 유지 + 중앙 스피너(또는 스켈레톤), `error:`는 `_EmptyState` 유사 위젯으로 문구 + "다시 시도"(`ref.invalidate(prayersForDateProvider)`) 버튼 |
| 회귀 위험 | 낮음. 단 loading에 스피너를 넣으면 날짜 스와이프/탭 전환마다 깜빡일 수 있어, 기존 데이터 유지(`AsyncValue.isLoading` + 이전 값 표시) 방식이 더 적절 |
| 검출 기법 | 6단계 4상태 매트릭스 점검 |

## PS-UI-04

| 항목 | 내용 |
|---|---|
| ID | PS-UI-04 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — settings_kit destructive→danger, 탈퇴 타일 destructive:true, Colors.red→danger 통일, danger 다크 분기 추가. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-008(탈퇴 시 서버 데이터 즉시 완전삭제, Q6), 6단계 항목 2(일관성)·8(실수 삭제 방지) |
| 위치 | `lib/screens/settings/account_screen.dart:137-142`, `lib/screens/settings/widgets/settings_kit.dart:116,128,134-135`, `lib/screens/write/prayer_write_screen.dart:82`, `lib/screens/community/group_detail_screen.dart:994` |
| 현상 | ① 회원탈퇴 타일이 로그아웃 타일과 시각적으로 완전히 동일하다 ② 파괴적 동작 확인 버튼 색이 앱 안에서 3가지로 갈린다 |
| 재현 절차 | 1. 설정→계정 진입 2. "로그아웃" 타일과 "회원탈퇴" 타일 비교 → 아이콘 글리프 외 색·굵기 동일 3. 기도문 삭제 확인 다이얼로그(빨강 `#F44336`), 편지 삭제 확인(벽돌색 `#C0392B`), 멤버 내보내기 확인(회색 `#4D4D4D`)을 비교 |
| 기대 결과 | 되돌릴 수 없는 파괴적 동작은 팔레트가 그 용도로 정의한 `AppColors.danger`(`app_colors.dart:29` "파괴적 동작(회원탈퇴 등) 강조")로 일관되게 구분 |
| 실제 결과 | `SettingsTile(icon: Icons.person_remove_outlined, title: l.accountWithdraw, showChevron: false, onTap: ...)` — **`destructive: true`를 넘기지 않는다.** 게다가 `settings_kit.dart:134-135`는 destructive를 `AppColors.danger`가 아니라 **`AppColors.accent`(회색)**에 매핑한다. `grep "destructive: true"` 결과 앱 전체에서 `SettingsTile`에 true를 넘기는 곳이 0건이라 **해당 파라미터는 죽어 있다** |
| 근본 원인 | 설정 키트 제작 시 destructive 색을 accent로 잘못 매핑했고, 호출부에서도 플래그를 누락. 삭제 확인 색은 화면별로 각자 하드코딩(`Colors.red` 직접 사용 1곳) |
| 수정 제안 | ① `settings_kit.dart:134-135`의 `AppColors.accent` → `AppColors.danger` ② `account_screen.dart:137-142`에 `destructive: true` 추가 ③ `prayer_write_screen.dart:82` `Colors.red` → `AppColors.danger` ④ `group_detail_screen.dart:994` 내보내기 확인도 `AppColors.danger`로 통일. **단 `danger`는 다크 card 대비 2.85:1이라 PS-UI-02와 함께 다크 분기를 넣어야 실효가 있다** |
| 회귀 위험 | 낮음(색·플래그 변경). 탈퇴 타일이 빨갛게 바뀌므로 시각 회귀 스크린샷 확인 권장 |
| 검출 기법 | 6단계 일관성 심사 — 파괴적 동작 색상 전수 대조 + 미사용 파라미터 추적 |

## PS-UI-05

| 항목 | 내용 |
|---|---|
| ID | PS-UI-05 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — GroupFullException 도입, commonError 10곳 전부 ARB 문구로 교체(원문은 debugPrint로만). `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC 10장 에러 카탈로그, 6단계 항목 5(개발자 용어 노출·한영 리소스) |
| 위치 | `community_letter_write_screen.dart:88`, `community_screen.dart:116`, `create_group_screen.dart:50`, `group_detail_screen.dart:663,1007`, `group_info_screen.dart:196`, `join_group_screen.dart:41`, `notice_write_screen.dart:43`, `recent_records_section.dart:27`, `community_provider.dart:220` |
| 현상 | 예외 객체를 `toString()` 그대로 사용자에게 보여준다. 한 경로는 미번역 한국어까지 섞인다 |
| 재현 절차 | 1. 앱 언어를 English로 변경 2. 정원이 가득 찬 모임의 초대 코드로 참여 시도 3. 스낵바 문구 확인 |
| 기대 결과 | 사용자 언어로 된, 원인+해결책을 말하는 문구 |
| 실제 결과 | **`Error: Exception: 그룹 인원이 꽉 찼습니다 (10명)`** — ①`Exception:` 개발자 용어 ②영어 UI에 한국어 ③예외 원문이 한 문장에 전부 노출. 오프라인이면 `Error: SocketException: Failed host lookup: 'ljtsytknzfcuahqtbmqe.supabase.co'`처럼 **Supabase 프로젝트 URL까지 노출** |
| 근본 원인 | ARB `commonError`가 `"오류: {error}"`로 placeholder에 예외를 그대로 받도록 설계됨(`app_ko.arb:171-172`). 도메인 오류를 `Exception('한국어 문자열')`로 던지는 코드(`community_provider.dart:220`)가 그 위에 얹힘 |
| 수정 제안 | ① 도메인 오류를 타입 있는 예외(예: `GroupFullException`)로 바꾸고 호출부에서 ARB 키로 분기 ② `commonError` 사용처는 예외 원문 대신 일반 실패 문구 + 재시도(PS-UI-06)로 교체 ③ 진단이 필요하면 원문은 `debugPrint`로만 |
| 회귀 위험 | 낮음(문구 계층). 신규 ARB 키 추가 + `flutter gen-l10n` 필요 |
| 검출 기법 | 6단계 문구 심사 — `toString()` 전수 조사 + Dart 내 한글 리터럴 전수 조사 |

## PS-UI-06

| 항목 | 내용 |
|---|---|
| ID | PS-UI-06 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — ErrorRetryView 공용 위젯 신설 후 에러 분기 6곳에 재시도 버튼 연결. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | 6단계 요구 "Error에 재시도 버튼", SPEC 10장 "복구" 열 |
| 위치 | `.when(error:)` 11곳 전체 — `community_screen.dart:115`, `group_detail_screen.dart:525,663,1007`, `group_info_screen.dart:196`, `history_search_overlay.dart:135`, `home_screen.dart:233`, `month_titles_section.dart`, `recent_records_section.dart:25` 등 |
| 현상 | 에러 상태에 **재시도 수단이 앱 전체에 하나도 없다** |
| 재현 절차 | 1. 오프라인 전환 2. 커뮤니티 탭 진입 → 에러 문구 표시 3. 온라인 복귀 → 화면이 자동 갱신되지 않고, 다시 시도할 버튼도 없음 (탭을 벗어났다 돌아오거나 앱 재시작 필요) |
| 기대 결과 | 에러 상태에 "다시 시도" 버튼 제공 |
| 실제 결과 | 전수 grep(`retry|재시도|다시 시도`) 결과 Dart 코드에 재시도 컨트롤 0건. ARB 문구 7건이 "다시 시도해주세요"라고 안내만 하고 수단은 없음 |
| 근본 원인 | 에러 분기를 전부 정적 `Text`/`_EmptyState`로만 구현 |
| 수정 제안 | 공용 `ErrorRetryView(message, onRetry)` 위젯 신설 후 `onRetry: () => ref.invalidate(해당 provider)`로 연결. 최소한 P0 화면(홈·기록)부터 |
| 회귀 위험 | 낮음(추가만). 위젯 신설 후 각 에러 분기 교체 |
| 검출 기법 | 6단계 4상태 심사 |

## PS-UI-07

| 항목 | 내용 |
|---|---|
| ID | PS-UI-07 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 테마 시트의 system 제외 필터 제거, MediaQuery.platformBrightnessOf로 실시간 반영. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major (단 FR-010은 P2) |
| 관련 요구사항 | **FR-010 "다크모드 시스템/수동 선택"** — 명세가 system 모드를 요구 |
| 위치 | `lib/screens/settings/app_settings_screen.dart:28`, `lib/screens/auth/signup_step3_screen.dart:160-182`, `lib/providers/settings_provider.dart:20,30` |
| 현상 | 테마를 **기기 설정 따라가기(시스템)로 선택할 수 있는 UI가 앱 어디에도 없다.** 기본값도 시스템이 아니라 라이트다 |
| 재현 절차 | 1. 기기를 다크 모드로 설정 2. 앱 신규 설치·실행 → **앱은 라이트로 뜬다** 3. 설정→앱설정→테마 → 시트에 "라이트"/"다크"만 있고 "시스템 설정"이 없다 4. 라이트를 선택한 뒤 다시 시스템으로 되돌릴 방법이 없다 |
| 기대 결과 | FR-010대로 system/light/dark 3가지 선택 가능 |
| 실제 결과 | `for (final m in AppThemeMode.values.where((m) => m != AppThemeMode.system))` — **system을 명시적으로 필터링해 제외.** 회원가입 3단계도 라이트/다크 카드 2장만 제공. `ThemeModeNotifier()`의 기본값은 `AppThemeMode.light`(`settings_provider.dart:20`), 저장값 파싱 실패 시 폴백도 light(`:30`). 결과적으로 `AppThemeMode.system`은 **enum·분기 코드는 있으나 도달 불가**(`main.dart:74-77`, `signup_step3_screen.dart:45-47`, `app_settings_screen.dart:12,31`이 전부 죽은 분기) |
| 근본 원인 | 테마 선택 UI에서 system을 의도적으로 배제. `themeSystem` ARB 키(ko "시스템 설정" / en "System")는 이미 존재하는데 쓰이지 않음 |
| 수정 제안 | `app_settings_screen.dart:28`의 `.where(...)` 제거(ARB·아이콘 분기 모두 이미 준비돼 있어 필터만 빼면 동작). 기본값을 system으로 바꿀지는 별도 판단(바꾸면 기존 사용자 체감 변화 있음) |
| 회귀 위험 | 낮음. system 선택 시 `main.dart:74-77`이 `platformBrightness`를 읽는데, **앱 실행 중 기기 테마가 바뀌어도 자동 갱신되지 않는다**(`WidgetsBindingObserver` 미등록) — 함께 확인 필요 |
| 검출 기법 | 6단계 다크모드 심사 → 명세(FR-010) 대조 |

## PS-UI-08

| 항목 | 내용 |
|---|---|
| ID | PS-UI-08 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — _ensurePermission()으로 권한 결과 확인 — 거부 시 알람 켜지 않고 안내. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | **FR-011 "설정 시각에 알림 수신"** (P1) |
| 위치 | `lib/screens/settings/notification_settings_screen.dart:42, 119` |
| 현상 | OS 알림 권한을 거부해도 알람 토글이 ON으로 켜지고, 사용자는 알람이 설정된 것으로 믿게 된다 |
| 재현 절차 | 1. 앱 알림 권한을 거부 상태로 만든다(설정→앱→알림 끄기, 또는 최초 권한 팝업에서 거부) 2. 설정→앱설정→알림 3. "알림 추가"로 시각 선택 → 알람이 목록에 ON 상태로 추가됨 4. 해당 시각이 되어도 알림이 오지 않음 |
| 기대 결과 | 권한이 없으면 토글이 켜지지 않거나, "알림 권한이 필요해요 · 설정 열기" 안내 표시 |
| 실제 결과 | `await NotificationService.requestPermission();` — **반환값을 버린다.** 권한 거부와 무관하게 다음 줄에서 `addAlarm`/`toggleAlarm`이 그대로 실행된다 |
| 근본 원인 | `NotificationService.requestPermission()`은 `Future<bool>`로 승인 여부를 정확히 돌려주는데(`notification_service.dart:46-52`) 호출부 2곳이 결과를 무시. Android 13+는 2회 거부 후 재요청 팝업조차 뜨지 않아 사용자가 원인을 알 방법이 없다 |
| 수정 제안 | `final granted = await NotificationService.requestPermission(); if (!granted) { 안내 스낵바 + 앱 설정 열기 유도; return; }` — 2곳 모두. 신규 ARB 키 필요 |
| 회귀 위험 | 낮음. 이미 권한을 준 사용자 동작엔 변화 없음 |
| 검출 기법 | 6단계 피드백·상태표시 심사 — 반환값 미사용 추적 |

## PS-UI-09

| 항목 | 내용 |
|---|---|
| ID | PS-UI-09 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 검색 0건 문구, 지난기록 빈 상태 카드, 통계 실패 시 0 대신 — 표시. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | FR-009(검색), FR-014(기록 조회), 6단계 항목 1·9 |
| 위치 | `history_search_overlay.dart:144`, `recent_records_section.dart:31`, `stats_summary_row.dart:24-27` |
| 현상 | 빈 결과·실패가 **아무 표시 없이 사라지거나 0으로 위장**된다 (3곳) |
| 재현 절차 | (a) 1. 기록탭 하단 검색창에 어떤 기록과도 안 맞는 단어 입력 → **결과 패널이 아예 뜨지 않아 검색이 동작했는지조차 알 수 없음** / (b) 신규 계정으로 기록탭 진입 → "지난 기록" 섹션이 통째로 없음 / (c) 통계 조회 실패 시 → "0일 / 0회"로 표시 |
| 기대 결과 | (a) "검색 결과가 없어요" (b) 첫 사용자 안내 (c) 실패와 0건의 구분 |
| 실제 결과 | (a) `if (items.isEmpty) return const SizedBox.shrink();` — PS-CRUD-04 수정으로 `data`가 빈 리스트를 정직하게 신뢰하게 되면서 **0건 결과가 무표시로 귀결됨** (b) `if (list.isEmpty) return const SizedBox.shrink();` (c) `whenOrNull(data:)`만 반영하고 error 분기가 없어 `_lastStats`가 null인 채 `?? 0` 폴백 |
| 근본 원인 | 세 지점 모두 "표시할 게 없으면 위젯을 지운다"는 처리. (c)는 에러를 정상 데이터(0)로 오표시하는 무음 실패 |
| 수정 제안 | (a) 빈 결과 문구 추가 (b) 첫 사용자용 안내 카드 (c) `statsAsync`에 error 분기 추가 — 실패 시 `—` 또는 재시도 |
| 회귀 위험 | 낮음 |
| 검출 기법 | 6단계 4상태·첫사용자경험 심사 |

## PS-UI-10

| 항목 | 내용 |
|---|---|
| ID | PS-UI-10 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 로그인 3경로·프로필저장·탈퇴·피드백에 catch(_) 보강. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC 10장 "네트워크 없음/타임아웃 구분 처리: 없음 ⚠️", QA 범위표 "인증 = P0 필수" |
| 위치 | `login_screen.dart:48,75-80,97`, `profile_edit_screen.dart:108`, `account_screen.dart:58`, `feedback_screen.dart:74` |
| 현상 | 네트워크 예외가 catch되지 않아 **버튼을 눌러도 아무 반응이 없다**(무응답) |
| 재현 절차 | 1. 기기를 완전 오프라인으로 전환(`svc wifi disable` + `svc data disable`) 2. 로그인 화면에서 이메일/비밀번호 입력 후 "로그인" 탭 3. 스피너가 잠깐 돌고 사라질 뿐 **에러 안내가 없다** — 비밀번호 오류인지 네트워크 문제인지 구분 불가 |
| 기대 결과 | PS-FLOW-01 수정과 동일하게 "네트워크를 확인해주세요" 계열 안내 |
| 실제 결과 | `on AuthException` / `on PostgrestException` / `on FunctionException`만 잡고 `SocketException`·`ClientException`은 통과. `finally`가 로딩 플래그만 되돌려 UI는 초기 상태로 복귀 |
| 근본 원인 | **PS-FLOW-01(회원가입 3단계 네트워크 예외 무처리)과 동일한 결함 패턴인데, 당시 수정이 `signup_step3_screen.dart`에만 적용되고 나머지 화면에는 전파되지 않았다.** 특히 `account_screen.dart:58`은 회원탈퇴(FR-008, 되돌릴 수 없는 P0 동작)라 무응답 영향이 크다 |
| 수정 제안 | 각 지점의 마지막에 `catch (_) { _snack(적절한 실패 문구); }` 추가 — PS-FLOW-01·PS-CRUD 수정과 동일 처방 |
| 회귀 위험 | 낮음(안내 추가만). 단 `login_screen.dart`의 구글 취소 경로(`GoogleSignInExceptionCode.canceled`)는 **조용히 무시가 정상 UX**이므로 광범위 catch가 이를 삼키지 않도록 순서 유지 |
| 검출 기법 | 6단계 4상태·에러처리 심사 (일부 지점은 1·3단계에서 관찰만 되고 미등록 상태였음 — 여기서 정식 등록) |

## PS-UI-11

| 항목 | 내용 |
|---|---|
| ID | PS-UI-11 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — AppInfo 상수 신설 후 3곳 치환. `flutter analyze` error/warning 0 |
| 심각도 | S3 Major (배포 버전 bump 직전이라 시급) |
| 관련 요구사항 | SPEC-GAP (버전 표기 규칙은 명세에 없음) |
| 위치 | `settings_screen.dart:98`, `feedback_screen.dart:66`, `feedback_screen.dart:92` |
| 현상 | 앱 버전 문자열이 3곳에 하드코딩돼 있어 `pubspec.yaml` bump 시 자동으로 갱신되지 않는다 |
| 재현 절차 | 1. `pubspec.yaml`의 `version: 1.0.0+1`을 `1.0.1+2`로 변경 2. 재빌드 3. 설정 화면 하단은 여전히 "v1.0.0" 4. 피드백을 보내면 `feedback.app_version` 컬럼에 여전히 `1.0.0+1`이 저장됨 |
| 기대 결과 | 실제 빌드 버전이 표시·기록됨 |
| 실제 결과 | 현재는 `pubspec.yaml:5`와 우연히 일치하지만, **다음 예정 작업이 배포용 버전 bump**라 즉시 어긋난다 |
| 근본 원인 | 빌드 메타데이터를 읽지 않고 리터럴 사용 |
| 수정 제안 | `package_info_plus`로 `PackageInfo.fromPlatform()` 사용, 또는 최소한 상수 1곳으로 모으고 bump 체크리스트(`docs/deploy_checklist.md`)에 항목 추가 |
| 회귀 위험 | 낮음. 단순 표시가 아니라 **피드백 DB에 잘못된 버전이 쌓이면 사용자 제보를 버전별로 분류할 수 없다**는 점에서 표시용보다 영향이 크다 |
| 검출 기법 | 6단계 문구 심사 — 하드코딩 리터럴 전수 조사 |

## PS-UI-12

| 항목 | 내용 |
|---|---|
| ID | PS-UI-12 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 내보내기 IconButton 48dp, 달력 셀 45.1dp(360dp 기준), FAB InkWell+Semantics, 탭 Semantics 라벨 l10n화. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC 9장 "접근성: 터치타깃 ≥48dp", 6단계 항목 3(피드백)·7(접근성) |
| 위치 | 터치타깃: `group_detail_screen.dart:1059-1063`, `prayer_calendar.dart:402-409` / 피드백: `main.dart:245-256` 외 `GestureDetector` 23곳 / Semantics: `main.dart:283-313` |
| 현상 | ① 멤버 내보내기 버튼이 48dp 미달 ② 좁은 화면에서 달력 셀이 48dp 미달 ③ 주요 탭 대상에 눌림 표현이 없다 ④ 하단 탭 라벨이 렌더도 Semantics 연결도 안 된다 |
| 재현 절차 | ① 모임 상세→멤버 탭(방장 계정)→멤버 옆 내보내기 아이콘 탭 시도 ② 360dp 폭 기기에서 달력 날짜 탭 ③ 하단 중앙 `+` 버튼을 눌러 유지 → 눌림 표현 없음(옆 탭 아이콘은 리플 있음) |
| 기대 결과 | 터치타깃 ≥48dp, 모든 탭 대상에 즉각 시각 반응 |
| 실제 결과 | ① `GestureDetector` + `Icon(size: 19)` + `Padding(left: 8)` ≈ **27×19dp**. **PS-ACT-02에서 공지·편지 삭제 X를 `IconButton(minWidth/minHeight 48)`로 고친 것과 동일 결함인데 이 지점만 누락** ② 좌우 여백 합 56dp ÷ 7열 → 360dp 화면 **43.4dp**(392dp 이상은 48dp 충족) ③ `GestureDetector` 23 vs `InkWell` 9. 설정 타일은 `InkWell`이나 splash가 `accent.withOpacity(0.06)`(`settings_kit.dart:141-142`)로 다크에선 사실상 안 보임 ④ `_NavItem.label`은 build에서 전혀 사용되지 않는 죽은 파라미터(값도 하드코딩 한국어) |
| 근본 원인 | 시각 스타일을 직접 그리려고 `InkWell` 대신 `GestureDetector`를 관행적으로 사용 |
| 수정 제안 | ① 내보내기를 `IconButton(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`로 교체 ② 달력 셀은 좌우 패딩 축소 또는 최소 높이 보장 ③ 주요 탭 대상을 `InkWell`/`InkResponse`로 교체(특히 FAB) ④ `_NavItem`을 `Semantics(label: ...)`로 감싸고 라벨을 ARB로 이전 |
| 회귀 위험 | 낮음~중간(레이아웃 미세 변화). 달력 패딩 조정은 PS-UI-01 폰트배율 재검증과 함께 확인 |
| 검출 기법 | 6단계 피드백·접근성 심사 + 터치타깃 산술 계산 |

## PS-UI-13

| 항목 | 내용 |
|---|---|
| ID | PS-UI-13 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — textHint 라이트/다크 상향, 아바타 그라데이션 어둡게, 미래날짜 토큰화, 다크 FAB 테두리. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC 9장 "대비 ≥4.5:1" |
| 위치 | `app_colors.dart:16`(textHint), `group_detail_screen.dart:934,1039-1040,943,946,1043`(아바타), `prayer_calendar.dart:355`(미래날짜), `app_colors.dart:27`+`main.dart:250-254`(FAB) |
| 현상 | PS-UI-02(다크 accent) 외에 남는 대비 미달 4종 |
| 재현 절차 | 1. 라이트 모드에서 설정 화면의 부제·힌트 텍스트 확인 2. 모임 상세→멤버 목록에서 일반 멤버(방장 아님) 아바타의 이니셜 확인 3. 기록탭 달력의 미래 날짜 숫자 확인 4. 다크 모드에서 하단 `+` 버튼의 원형 경계 확인 |
| 기대 결과 | 일반 텍스트 4.5:1, UI 컴포넌트 3:1 |
| 실제 결과 | ① **textHint 라이트: background 3.32 / card 3.02 / bottomBar 2.67** — 부제·힌트·날짜·플레이스홀더 전반에 쓰이는 색이라 노출 면적이 가장 넓다 ② **아바타 이니셜 흰글씨 on `#D9C9A8` = 1.63:1**(거의 안 보임), `#B07A6A` = 3.60:1도 텍스트 기준 미달. 두 그라데이션 모두 테마 분기 없음 ③ **미래날짜 `#AA9880` on 라이트 card = 2.55:1**(단 `onTap: null`인 비활성 요소라 WCAG 비활성 예외 적용 여지 있음 — 판정 보류 근거로 명시) ④ **FAB `#000000` vs 다크 bottomBar `#121212` = 1.12:1** — 원형 자체가 배경에 녹고 흰 `+`만 떠 보임(아이콘 대비 21:1이라 기능은 정상) |
| 근본 원인 | 팔레트 설계 시 라이트 textHint를 배경 대비가 아니라 "종이 위 연한 글씨" 감성 기준으로 잡음. 아바타·FAB은 테마 분기 자체가 없음 |
| 수정 제안 | ① 라이트 textHint를 `#7A6A5C` 수준으로 어둡게(4.5:1 확보) ② 아바타 그라데이션을 어둡게 하거나 이니셜을 어두운 글자로 ③ 미래날짜는 성헌 판정 후 처리 ④ 다크에서 FAB에 테두리 또는 밝은 배경 부여 |
| 회귀 위험 | 중간 — textHint는 사용 지점이 매우 많아 톤 변화가 앱 인상을 바꾼다. 라이트 전 화면 스크린샷 재검증 필요 |
| 검출 기법 | 6단계 다크모드·접근성 심사 — 팔레트 전수 대비비 계산 |

## PS-UI-14

| 항목 | 내용 |
|---|---|
| ID | PS-UI-14 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — AppColors.isDark로 ColorScheme.dark/light 분기. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor (실기기 확인 결과에 따라 상향 가능) |
| 관련 요구사항 | FR-010(다크모드), FR-011(알림 설정) |
| 위치 | `lib/screens/settings/notification_settings_screen.dart:24-34` |
| 현상 | 시간 선택 다이얼로그가 앱 테마와 무관하게 라이트 `ColorScheme`으로 고정된다 |
| 재현 절차 | 1. 테마를 다크로 설정 2. 설정→앱설정→알림→"알림 추가" 3. 시간 선택 다이얼로그의 다이얼·숫자·선택 하이라이트 확인 |
| 기대 결과 | 다크 모드에서는 다크 다이얼로그 |
| 실제 결과 | **미확인(정적 분석으로 확정 불가).** 코드상 `ColorScheme.light(primary:, onPrimary:, surface:, onSurface:)`를 강제하는데, 덮어쓴 4개 슬롯만 앱 색을 따르고 나머지(다이얼 배경 `surfaceContainerHighest`, 선택 하이라이트 `secondaryContainer`/`onSecondaryContainer`, `outline` 등)는 **라이트 기본값이 남는다.** `surface`에 다크 `#242424`가 들어가므로 어두운 면 위에 라이트용 밝은/어두운 요소가 섞일 것으로 보이나, 실제 파손 정도는 렌더 확인 필요 |
| 근본 원인 | 테마 분기 없이 `ColorScheme.light` 하드코딩 |
| 수정 제안 | `AppColors.isDark ? ColorScheme.dark(...) : ColorScheme.light(...)` 분기 |
| 회귀 위험 | 낮음 |
| 검출 기법 | 6단계 다크모드 심사 — 강제 `ColorScheme` 전수 조사 |

## PS-UI-15

| 항목 | 내용 |
|---|---|
| ID | PS-UI-15 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 저장 중 스피너 표시 + 버튼 색에 _isSaving 반영. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC 5장 "Loading(저장중): 저장 버튼 비활성, **but 진행 인디케이터 없음 ⚠️**" (명세에 이미 기록된 미해결 항목) |
| 위치 | `lib/screens/write/prayer_write_screen.dart:351-359` |
| 현상 | 기도문 저장 중 진행 표시가 없고, 저장 버튼 색이 저장 중 상태를 반영하지 않는다 |
| 재현 절차 | 1. 느린 네트워크에서 기도문 작성 후 "기록하기" 탭 2. 화면에 아무 변화가 없다(버튼만 비활성) 3. 다크 모드에서 같은 버튼의 활성/비활성 색을 비교 |
| 기대 결과 | 저장 중 스피너 표시 + 상태에 맞는 버튼 색 |
| 실제 결과 | `onPressed: _isSaving \|\| !_canSave ? null : _save`로 비활성화는 되지만 인디케이터 없음. 색은 `color: _canSave ? AppColors.accent : AppColors.textHint`로 **`_isSaving`을 반영하지 않아** 저장 중에도 활성 색으로 보인다. 다크에선 accent 2.48:1 < textHint 6.05:1이라 **활성이 비활성보다 흐린 역전**이 발생 |
| 근본 원인 | 로그인·가입3단계는 버튼 내 스피너를 구현했으나(`login_screen.dart:265-271`, `signup_step3_screen.dart:200-206`) 작성 화면에만 미적용 |
| 수정 제안 | `_isSaving`일 때 버튼 자리에 `SizedBox(16,16, child: CircularProgressIndicator(strokeWidth: 2))`, 색 조건에 `_isSaving` 포함 |
| 회귀 위험 | 낮음 |
| 검출 기법 | 6단계 4상태·일관성 심사 |

## PS-UI-16

| 항목 | 내용 |
|---|---|
| ID | PS-UI-16 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 한국어 저장하기/삭제하기/수정하기로 어미 통일(영어는 기존 유지). `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | 6단계 항목 2(같은 의미 버튼 라벨 일관성) |
| 위치 | `lib/l10n/app_ko.arb` / `app_en.arb` — `buttonSave`(:259), `writeSubmitEdit`(:145), `writeSubmitToday`(:146), `writeSubmitOther`(:147), `profileEditButton`(:330), `buttonPost`(:225), `buttonDone`(:341), `feedbackSendButton`(:298), `buttonDelete`(:138), `letterDeleteButton`(:322), `noticeDeleteButton`(:325) |
| 현상 | "폼을 확정한다"는 같은 동작에 8가지 라벨, "삭제한다"에 2가지 라벨이 쓰인다 |
| 재현 절차 | 기도문 작성("기록하기") → 프로필 수정("수정하기") → 모임 이름 변경("저장") → 공지 작성("등록") → 피드백("보내기") 순회 |
| 기대 결과 | 동일 동작은 동일 라벨. 화면 성격상 다르게 쓸 곳은 근거가 있어야 함 |
| 실제 결과 | 저장 계열: 저장 / 저장하기 / 기록하기 / 수정 / 수정하기 / 등록 / 완료 / 보내기. 삭제 계열: 삭제(기도문) vs 삭제하기(편지·공지) |
| 근본 원인 | 화면별로 ARB 키를 개별 추가하며 표기 통일 규칙 부재 |
| 수정 제안 | "기록하기"처럼 서신 은유가 의도된 것은 유지하되, **저장/저장하기·수정/수정하기·삭제/삭제하기의 어미 불일치는 한쪽으로 통일.** 성헌이 표기 기준(예: "-하기"로 통일) 확정 후 일괄 반영 |
| 회귀 위험 | 없음(문구만) |
| 검출 기법 | 6단계 일관성 심사 — ARB 라벨 전수 대조 |

## PS-UI-17

| 항목 | 내용 |
|---|---|
| ID | PS-UI-17 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — AppThemeModeLabel·SettingsProfileHeader 제거, _NavItem.label은 Semantics로 연결. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | 없음 (클린업 — 8단계 선행 자료) |
| 위치 | 아래 표 |
| 현상 | 완성돼 있으나 아무도 쓰지 않는 코드가 6종 남아 있다 |
| 재현 절차 | 정적 grep (아래 근거) |
| 기대 결과 | 미사용 코드 제거 또는 연결 |
| 실제 결과 | ① `SettingsProfileHeader`(`settings_kit.dart:209-301`, 93줄) — 참조 **0건** ② `PrayerStats.streakCount`(`prayer_provider.dart:157,208`) — 계산만 하고 표시 **0건**(연속기록 카드가 "응답" 카드로 교체된 흔적) ③ `_NavItem.label`(`main.dart:288,239,262,269`) — 렌더 안 됨 + 하드코딩 한국어 ④ `SettingsTile.destructive`(`settings_kit.dart:116`) — `true` 호출 **0건**(PS-UI-04 참조) ⑤ `AppThemeModeLabel`(`settings_provider.dart:9-15`) — 하드코딩 한국어 라벨, 실제로는 로케일화된 `themeModeLabel()` 사용 ⑥ `AppThemeMode.system` 분기 3곳(`main.dart:74-77`, `signup_step3_screen.dart:45-47`, `app_settings_screen.dart:31`) — 도달 불가(PS-UI-07 참조) |
| 근본 원인 | 리팩토링 과정에서 대체된 코드가 제거되지 않음 |
| 수정 제안 | ②③⑤는 삭제, ①은 설정 화면에 연결할지 삭제할지 판단, ④⑥은 PS-UI-04/07 수정 시 자연히 살아남 |
| 회귀 위험 | 낮음. 단 1단계에서 확정된 "고아 기능은 그대로 두고 마무리" 방침과 별개 항목인지 성헌 확인 필요 |
| 검출 기법 | 6단계 심사 중 부수 발견 — 참조 전수 조사 |

## PS-UI-18

| 항목 | 내용 |
|---|---|
| ID | PS-UI-18 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — 중복 이메일 시 1단계까지 자동 복귀. `flutter analyze` error/warning 0 |
| 심각도 | S4 Minor |
| 관련 요구사항 | 6단계 항목 4(스택 깊이·데드엔드) |
| 위치 | `lib/screens/auth/signup_step1_screen.dart:36-61`, `lib/screens/auth/signup_step3_screen.dart:71,100-102` |
| 현상 | 이미 가입된 이메일인지를 회원가입 **3단계를 다 채운 뒤에야** 알려준다 |
| 재현 절차 | 1. 이미 가입된 이메일로 회원가입 시작 2. 1단계(이메일/비번) 통과 3. 2단계 프로필(이름/교회/성별/연령대) 전부 입력 4. 3단계 테마 선택 후 "PrayStory 시작하기" → **여기서야** "이미 가입된 이메일이에요" 스낵바 |
| 기대 결과 | 가급적 1단계에서 검출하거나, 실패 시 1단계로 되돌려 이메일만 수정하게 함 |
| 실제 결과 | 1단계는 형식 검증만(`RegExp`, 길이 6, 일치 확인) 수행하고 서버 조회를 하지 않는다. 실제 `signUp()`은 3단계에서 최초 호출되며, 실패 시 **자동 복귀가 없어** 사용자가 뒤로 2번 눌러 재입력해야 한다 |
| 근본 원인 | "가입 즉시 세션이 생기면 온보딩 스택이 날아간다"는 이유로 최종 커밋을 3단계에 몰아둔 설계(의도된 구조). 다만 실패 시 복귀 처리가 빠졌다 |
| 수정 제안 | 최소 조치로 `errAlreadyRegistered` 발생 시 1단계까지 `Navigator.popUntil`로 되돌리고 이메일 필드에 포커스. (사전 중복 조회는 사용자 열거 취약점이 될 수 있어 권장하지 않음) |
| 회귀 위험 | 낮음. OAuth 온보딩 경로(`email == null`)에는 해당 없음 |
| 검출 기법 | 6단계 내비게이션 심사 — 가입 플로우 추적 |

## PS-UI-19

| 항목 | 내용 |
|---|---|
| ID | PS-UI-19 |
| 상태 | **✅ 수정 완료 (2026-07-27)** — accountWithdrawConfirm·accountWithdrawNote를 ko/en 모두 "즉시 영구 삭제·복구 불가" 문구로 교체(성헌 확정). gen-l10n 재생성, `flutter analyze` error/warning 0 |
| 심각도 | **S2 Critical** (데이터 유실 오인 유도 + 개인정보 고지 불일치) |
| 관련 요구사항 | **FR-008**, SPEC 0장 **Q6("확정: 즉시 완전삭제. 유예기간 없음")** |
| 위치 | `lib/l10n/app_ko.arb:399,402` / `app_en.arb:399,402` (`accountWithdrawConfirm`, `accountWithdrawNote`) |
| 현상 | 회원탈퇴 안내 문구가 **"비활성화"라고 설명**하는데 실제로는 **즉시 완전 삭제**된다 |
| 재현 절차 | 1. 설정 → 계정 진입 2. 하단 안내문 확인 3. "회원 탈퇴" 탭 후 확인 다이얼로그 문구 확인 |
| 기대 결과 | FR-008/Q6대로 "계정과 모든 기도 기록이 즉시 영구 삭제되며 복구할 수 없다"는 사실이 명확히 고지돼야 함 |
| 실제 결과 | 화면: "탈퇴 시 계정은 **비활성화** 처리돼요. 작성하신 기도 기록의 완전 삭제를 원하시면 피드백으로 문의해 주세요." / 다이얼로그: "탈퇴하면 계정이 **비활성화**되고 더 이상 로그인할 수 없어요." — 둘 다 소프트 삭제를 설명 |
| 근본 원인 | 2026-06-30 최초 구현은 `profiles.deleted_at` 소프트 삭제였고 이후 `delete-account` Edge Function(하드 삭제)으로 바뀌었으나 **문구만 그대로 남았다.** Edge Function 소스(`supabase/functions/delete-account/index.ts`)가 `admin.deleteUser`로 auth.users를 지우고 profiles/prayers/feedback + 커뮤니티 데이터가 ON DELETE CASCADE로 함께 삭제됨을 확인 |
| 수정 제안 | ko `accountWithdrawNote`: "탈퇴하면 계정과 작성하신 모든 기도 기록이 **즉시 영구 삭제**되며 복구할 수 없어요." / `accountWithdrawConfirm`: "탈퇴하면 계정과 모든 기도 기록이 **즉시 삭제되고 복구할 수 없어요.**\n정말 탈퇴하시겠어요?" (영문 동일 취지). **문구 확정은 성헌 판정 필요 — 개인정보처리방침·Play 데이터 세이프티 신고 내용과 3자 일치시켜야 함(SPEC 9장)** |
| 회귀 위험 | 없음(문구만). 단 개인정보처리방침 문서도 함께 갱신해야 정합 |
| 검출 기법 | QA 6단계 **실기기 검증 중 발견** — 정적 리뷰에서는 ARB 문구와 Edge Function 동작을 대조하지 않아 놓쳤음 |

---

## 2026-08-04 — 비공개 테스트 실사용자(가족) 피드백 8건 조사

> 성헌이 비공개 테스트 중 어머니·아내 등 실사용자로부터 접수한 8건 보고. 코드 정적 분석만 수행(2~6단계 미착수 상태에서의 애드혹 조사), 실기기 재현은 아직 성헌이 직접 하지 못함 — 아래 "근본 원인"은 코드 근거는 확실하나 **실기기 재확인 전까지는 PLAUSIBLE로 취급할 것.**

## PS-AUTH-05

| 항목 | 내용 |
|---|---|
| ID | PS-AUTH-05 |
| 상태 | **✅ 수정 완료 + 검증 완료 (2026-08-05)** — **원인 A(OAuth 동의 화면 테스트 모드)는 반증됨.** 게시 상태를 "프로덕션"으로 바꾼 뒤에도 테스터 전원이 동일 증상 지속. 재조사 결과 **진짜 원인은 Play 앱 서명 키 SHA-1 미등록**으로 확정(아래 "근본 원인" 참고). Google Cloud Console에 앱 서명 키 SHA-1로 Android OAuth 클라이언트를 추가 생성 → **재검증에서 구글 로그인 성공 확인.** 코드 변경·재빌드·재업로드 없이 콘솔 설정만으로 해소됨 |
| 심각도 | **S1 Blocker** (본인 외 계정 로그인 불가 = 비공개 테스트 자체가 불가능한 상태) |
| 관련 요구사항 | FR 없음 — SPEC 3장 인증 플로우 전제 위반 |
| 위치 | `lib/screens/auth/login_screen.dart:27-54`(`_loginWithGoogle`), `lib/main.dart:109-140`(`_RootGate`), `lib/providers/profile_provider.dart:5-18` |
| 현상 | 개발자 본인 구글 계정은 로그인이 되는데, 어머니·아내 등 다른 구글 계정으로는 계정 선택 다이얼로그까지 뜬 뒤 로그인 화면으로 되돌아간다 |
| 재현 절차 | 1. 비공개 테스트 트랙으로 배포된 앱 설치 2. "Google로 시작하기" 3. 소유자 계정이 아닌 다른 구글 계정 선택 4. 로그인 화면으로 복귀됨(에러 문구 노출 여부 미확인) |
| 기대 결과 | 비공개 테스트에 등록된 테스터 누구나 자신의 구글 계정으로 로그인되어야 함 |
| 실제 결과 | 계정 선택 후 세션이 만들어지지 않거나(원인후보 A), 세션은 만들어지지만 화면이 로그인으로 되돌아감(원인후보 B) |
| 근본 원인 | **확정 원인(코드 밖 설정): Play 앱 서명 키의 SHA-1이 Google Cloud Console에 등록되지 않음.** Android 네이티브 구글 로그인은 요청한 앱의 `패키지명 + 서명 인증서 SHA-1` 조합이 같은 GCP 프로젝트의 **Android 유형 OAuth 클라이언트**에 등록돼 있어야만 ID 토큰을 발급한다. 그런데 Cloud Console에 등록돼 있던 SHA-1은 **업로드 키**(`0C:2C:32:5A:9F:96:43:EB:48:7F:AB:4B:E6:B9:DB:E2:00:A3:72:BD`, `android/upload-keystore.jks`) 하나뿐이었고, AAB로 올린 앱은 Google Play가 **앱 서명 키로 재서명**해서 배포하므로 실제 배포본의 지문은 `47:85:A6:7D:9A:A6:17:2C:F0:34:09:6E:55:19:44:AD:CF:E2:9C:39`로 전혀 다르다. 따라서 Play로 설치한 모든 사용자에게서 `GoogleSignIn.instance.authenticate()`(`login_screen.dart:31`)가 실패 → `GoogleSignInException` 경로(`:42-45`)로 빠져 Supabase 세션 자체가 생기지 않음. **결정적 증거:** ① Cloud Console 게시 상태를 "프로덕션"으로 바꿔도 증상 불변(원인 A 반증) ② 2026-07-29에 소유자 아닌 신규 계정 `praystorytest@gmail.com`으로 **로컬 빌드에서는 구글 로그인 성공**(`docs/deploy_checklist.md:474`) — 즉 계정별 차이가 아니라 **빌드(서명 인증서)별 차이**였다. "본인만 된다"가 아니라 "로컬 빌드만 된다"가 정확한 기술이다 |
| 수정 제안 | **(확정 원인) 조치 완료** — Google Cloud Console에 Android OAuth 클라이언트를 하나 더 생성(기존 업로드 키용 클라이언트는 로컬 빌드 테스트용으로 존치). 상세 값은 `docs/deploy_checklist.md`의 "구글 로그인 SHA-1 등록 현황" 절 참고. **코드 수정·재빌드·재업로드·재심사 전부 불필요**(Android 클라이언트 ID는 앱이 참조하지 않고 구글이 대조용으로만 쓴다. 코드의 `serverClientId`는 웹 클라이언트를 가리키며 변경 없음). **(별건, 코드 수정 필요)** ① `login_screen.dart:49`·`:73`의 `debugPrint('google signIn failed: ')`에 **에러 객체 `e`가 보간돼 있지 않아** 실패해도 logcat에 아무 단서가 남지 않는다 — 이번 진단이 오래 걸린 직접 원인이므로 우선 수정할 것. ② `_RootGate`(`main.dart:122-131`)는 `authStateProvider`·`profileProvider` 에러를 **원인 불문 무조건 `LoginScreen`으로 되돌린다**(`:124`, `:131`). 세션이 남아있어도 사용자에겐 원인이 전혀 안 보이므로, 에러 로그를 남기고 재시도 버튼이 있는 에러 화면으로 분리해 "로그인 자격 없음"과 "일시적 오류"를 구분해야 한다. 이번 건의 원인은 아니었으나 **같은 증상을 만드는 독립 경로로 여전히 잠재** |
| 회귀 위험 | 확정 원인 조치는 콘솔 설정 변경뿐이라 코드 회귀 없음. 다만 **기존 Android 클라이언트(업로드 키 SHA-1)를 지우면 로컬 빌드 구글 로그인이 깨진다** — 반드시 존치할 것. 수정 제안 ②(`_RootGate`) 착수 시엔 로그인/온보딩/메인 전환 전체 경로 회귀 테스트 필요 |
| 검출 기법 | 오류 추정(사용자 실사용 보고) → 가설 반증(동의 화면 프로덕션 전환 후에도 증상 불변) → **차이 분석**(성공한 로컬 빌드 vs 실패한 Play 배포본의 유일한 차이 = 서명 인증서) → 키스토어 지문 대조로 확정 |

## PS-FLOW-08

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-08 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-08-06).** 온보딩 화면 AppBar에 로그아웃 액션(`OnboardingLogoutAction`) 신설. `flutter analyze` error/warning 0(info 19건 전부 기존 항목), 위젯 테스트 3건 신규 추가·전부 PASS(`test/onboarding_escape_test.dart`). **실기기(SM S911N, Android 16) 검증**: 수정 전 baseline 재현 → 수정 후 로그아웃 버튼 노출·확인 다이얼로그·로그인 화면 복귀·앱 재시작 후에도 로그인 화면 유지(세션 실제 삭제 확인)까지 전 구간 PASS |
| 심각도 | **S2 Critical** (복구 불가 상태 진입·플로우 데드엔드) |
| 관련 요구사항 | SPEC 3장 "로그인(프로필 없음)" 역할 정의, `signup_step2_screen.dart` |
| 위치 | `lib/screens/auth/signup_step2_screen.dart:95-107`, `lib/screens/auth/widgets/profile_form.dart:447-501`(`OnboardingExitGuard`), `lib/main.dart:126-134`(`_RootGate`) |
| 현상 | 온보딩(프로필 입력) 중 다른 로그인 수단(카카오)으로 바꾸고 싶어 뒤로가기/앱종료 후 재실행해도 계속 같은 프로필 입력 화면만 뜬다 |
| 재현 절차 | 1. 구글로 로그인(신규, profiles 행 없음) → 온보딩(프로필 입력) 진입 2. 상단 AppBar 뒤로가기 탭 → **"앱을 종료할까요?" 다이얼로그**(아래 ⚠️정정 참고) 3. 시스템 뒤로가기 제스처 → 동일 다이얼로그(`OnboardingExitGuard`, `profile_form.dart:493-498`이 `PopScope(canPop:false)`로 뒤로가기를 항상 가로챔) 4. "종료" 선택 → 앱 프로세스 종료(`SystemNavigator.pop()`, `:488`) 5. 앱 재실행 → 여전히 같은 프로필 입력 화면 |
| ⚠️ 기록 정정 | 최초 기록(2026-08-04)은 2단계를 "AppBar 뒤로가기 → 아무 반응 없음(루트라 pop할 대상 없음)"으로 적었으나 **틀렸다.** `PopScope(canPop:false)`가 걸리면 라우트의 `popDisposition`이 `bubble`이 아니라 `doNotPop`으로 **강제**되고, `NavigatorState.maybePop()`은 `doNotPop`일 때 `onPopInvokedWithResult(false)`를 호출한다 → AppBar 뒤로가기도 종료 다이얼로그를 띄운다. 최초 기록이 `isFirst`만 보고 `PopScope` 오버라이드를 놓친 것. **테스트로 확정**(`onboarding_escape_test.dart` 3번째 케이스) |
| 기대 결과 | 온보딩 중에도 로그인 화면으로 돌아가거나 다른 계정/수단으로 전환할 방법이 있어야 함 |
| 실제 결과 | 온보딩 화면에는 로그아웃 버튼이 전혀 없다(`signOut()` 호출은 저장소 전체에서 `account_screen.dart` 한 곳뿐이며, 그 화면은 메인 앱(설정 탭) 안에 있어 프로필이 있어야만 도달 가능 — `_RootGate`가 프로필 없으면 무조건 온보딩으로 보내 메인 진입 자체가 막힘, `main.dart:133-135`). 앱을 완전히 종료해도 Supabase 세션은 기기에 남아있고 서버에도 profiles 행이 여전히 없으므로, 재실행 시 `_RootGate`가 다시 온보딩 화면으로 보낸다 — **사용자가 스스로 빠져나올 방법이 없는 루프** |
| 근본 원인 | "세션 있음+프로필 없음이면 무조건 온보딈" 게이트(`main.dart:133-134`)를 설계할 때, 온보딈 화면 자체에서 로그아웃/계정 전환이 가능해야 한다는 점이 반영되지 않음 |
| 수정 제안 | `SignupStep2Screen`(또는 `OnboardingExitGuard`)에 "다른 계정으로 로그인" 또는 "로그아웃" 액션 추가 — 탭 시 `supabase.auth.signOut()` 호출 후 `_RootGate`가 자연히 `LoginScreen`으로 전환되게 함. 최소 조치로는 종료 확인 다이얼로그에 "로그아웃하고 나가기" 선택지를 하나 더 추가 |
| 실제 수정 (2026-08-06) | `profile_form.dart`에 **`OnboardingLogoutAction`(ConsumerWidget)** 신설 — 확인 다이얼로그 → `LocalPrayerStore.clearAll()`(FR-007) → `auth.signOut()` → `popUntil(isFirst)`. `signup_step2_screen.dart`의 AppBar `actions:`에 배치. **다이얼로그 안에 숨기지 않고 화면에 상시 노출**한 이유는 이번 신고자가 탈출구를 못 찾은 것이 핵심이기 때문. ARB 1키 추가(`onboardingLogoutMessage` ko/en), 제목·버튼은 기존 `accountLogout` 재사용. 카카오·구글 모두 Supabase 세션이라 `signOut()` 한 번으로 정리됨(`login_screen.dart:37-40`, `:60-67`) |
| 회귀 위험 | 낮음 — 신규 액션 추가이며 기존 종료 흐름은 그대로 유지 가능 |
| 검출 기법 | 상태 전이 — 온보딈 상태에서 "로그아웃"이라는 불법 전이(정의조차 안 됨)를 시도한 케이스 |
| 실기기 검증 (2026-08-06, SM S911N / Android 16 / debug 빌드) | **수정 전 baseline**: 온보딩에 로그아웃 수단 없음 재현. **수정 후**: ① Step2 AppBar에 "로그아웃" 노출 ② 탭 → 확인 다이얼로그 ③ "로그아웃" → 로그인 화면 복귀 ④ `am force-stop` 후 재실행해도 로그인 화면 유지(= 세션이 실제로 삭제됨, 데드엔드 완전 해소) ⑤ 재로그인 → 온보딩 → 이름 입력 → 테마 선택 → **메인 진입까지 완주(회귀 없음)** ⑥ Step2(루트) 시스템 뒤로가기는 종전대로 종료 확인 다이얼로그 유지. **로그아웃 후 구글 계정 선택창도 다시 노출됨을 확인**(기존 미확인 항목 해소 — 계정 전환 가능) |
| 잔여 관찰 (S4 이하) | AppBar "로그아웃" 텍스트가 화면 우측 가장자리에 다소 근접(잘림은 없음). 필요 시 우측 패딩만 조정 가능 — 기능 영향 없어 백로그 |

## PS-UI-20

| 항목 | 내용 |
|---|---|
| ID | PS-UI-20 |
| 상태 | 미수정 |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC-GAP (줄지 배경선 표시는 FR에 명문화 안 된 장식 요소) |
| 위치 | `lib/screens/write/prayer_write_screen.dart:404-497`(`_LinesPainter`, `_NoteLinesPainter`) |
| 현상 | 기도문 작성/수정 화면에서 배경 밑줄(노트 줄 효과)이 실제 텍스트 줄과 어긋난다. 폰트 크기를 키우면 어긋나는 정도가 더 커진다 |
| 재현 절차 | 1. 기도문 작성/수정 화면 진입 2. 여러 줄 입력 3. 아래로 내려갈수록 텍스트와 배경 밑줄이 벌어지는지 확인 4. 설정에서 폰트 크기를 키운 뒤 동일 확인 → 어긋남 폭 증가 |
| 기대 결과 | 배경 밑줄이 실제 입력 텍스트의 각 줄 바로 아래에 위치해야 함 |
| 실제 결과 | 어긋남, 폰트 확대 시 심화 |
| 근본 원인 | 배경선은 `_LinesPainter`가 `lineHeight = fontSize * 2.2`라는 **자체 근사식**으로 독립 계산해 그리고(`:487`), 실제 텍스트는 같은 `Stack` 안의 `TextField`가 Flutter 엔진의 실제 텍스트 레이아웃(`style: height:2.2`, 폰트 자체 메트릭, `TextField`/`InputDecoration`의 내부 패딩 포함)으로 그린다(`:428-449`). **두 값이 항상 일치한다는 보장이 없는 서로 다른 두 계산 경로**이고, 실기기에서 실제로 어긋남이 관찰됨. `fontSize`가 커질수록 근사식과 실제 레이아웃의 절대 오차(px)도 비례해 커지므로 폰트 확대 시 더 심해지는 것과 부합. 같은 화면의 읽기용 밑줄(`home_screen.dart`의 `_UnderlinePainter`)은 실제 `TextPainter.computeLineMetrics()`로 그려 이 문제가 없어야 하는데(PS-UI-22 참고, 그쪽도 별도 문제 있음) 작성화면만 근사식을 쓰는 상태 |
| 수정 제안 | `_LinesPainter`를 `home_screen.dart`의 `_UnderlinePainter`처럼 `_contentController.text`를 `TextPainter`로 직접 레이아웃해 `computeLineMetrics()` 기반으로 다시 작성 — 근사식(`fontSize*2.2`) 제거. `TextField`의 `contentPadding`/내부 여백도 동일하게 반영해야 첫 줄부터 어긋나지 않음 |
| 회귀 위험 | 낮음 — 순수 장식 페인터 교체, 저장 로직 무관. 단 성능(매 keystroke마다 TextPainter 재레이아웃) 확인 필요 |
| 검출 기법 | 오류 추정 + 실사용자 보고(스크린샷) — 두 개의 독립된 레이아웃 계산 경로가 존재한다는 것 자체가 코드 근거 |

## PS-UI-21

| 항목 | 내용 |
|---|---|
| ID | PS-UI-21 |
| 상태 | 미수정 |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/write/prayer_write_screen.dart:428-438` |
| 현상 | 작성화면 본문 입력 커서(캐럿)가 커 보인다 |
| 재현 절차 | 기도문 작성화면에서 본문 입력란 탭 → 깜빡이는 커서 관찰 |
| 기대 결과 | 커서 크기가 글자 크기에 자연스럽게 비례해야 함 |
| 실제 결과 | 커서가 크게 느껴짐(사용자 보고) |
| 근본 원인 | 본문 `TextField`에 `cursorHeight`/`cursorWidth`가 **명시적으로 지정되어 있지 않아** Flutter 기본값을 그대로 쓰는데, 해당 `TextStyle`에 `height: 2.2`라는 이례적으로 큰 줄간격 배수가 걸려 있다(`:436`, PS-UI-20과 같은 원인 위치). Flutter의 기본 캐럿 높이는 해당 줄의 유효 줄높이를 기준으로 계산되므로, 줄간격 배수가 클수록 캐럿도 커 보이게 되는 것과 부합 |
| 수정 제안 | `TextField`에 `cursorHeight: fontSize * 1.2` 정도로 명시적으로 고정해 줄간격 배수와 분리 |
| 회귀 위험 | 없음 — 시각적 조정만 |
| 검출 기법 | 오류 추정 — `height:2.2`가 이례적으로 크다는 점에서 역추적 |

## PS-UI-22

| 항목 | 내용 |
|---|---|
| ID | PS-UI-22 |
| 상태 | 미수정 — 빈 줄 부분은 원인 미확정(확인 필요) |
| 심각도 | S3 Major |
| 관련 요구사항 | SPEC-GAP |
| 위치 | `lib/screens/home/home_screen.dart:355-421`(`_UnderlinedText`, `_UnderlinePainter`) |
| 현상 | 메인 읽기 화면(작성된 기도문을 다시 보는 화면)에서도 텍스트와 밑줄이 안 맞고, 특히 빈 줄(개행만 있는 부분)에도 밑줄이 그어져 있다 |
| 재현 절차 | 1. 여러 줄 + 빈 줄 여러 개를 포함한 기도문 저장 2. 홈 화면에서 해당 날짜 서신 열람 3. 텍스트-밑줄 정렬 및 빈 줄 부분 확인 |
| 기대 결과 | 밑줄은 실제 글자가 있는 줄에만, 글자 바로 아래에 그어져야 함 |
| 실제 결과 | 정렬 어긋남 + 빈 줄에도 밑줄 |
| 근본 원인 | 이 화면은 작성화면과 달리 `TextPainter(...).computeLineMetrics()`로 실제 레이아웃을 계산해 그리므로(`:390-413`) 원칙적으로는 정확해야 한다. 코드상 빈 줄은 `if (metric.width < 1.0) continue;`(`:406`)로 걸러지도록 되어 있으나, **실기기에서는 걸러지지 않는 사례가 보고됨 — 이 임계값(1.0px) 필터가 실패하는 조건을 코드만으로는 확정할 수 없어 미확인으로 남김.** 가능성 있는 후보: 빈 줄로 보이는 줄에 공백 등 미세한 문자가 남아 있어 폭이 0을 초과하는 경우, 혹은 폰트/텍스트 조합에 따라 `computeLineMetrics()`가 빈 줄에도 0을 초과하는 폭을 보고하는 경우 |
| 수정 제안 | `metric.width < 1.0` 같은 픽셀 임계값 대신, 원본 `text`를 `\n` 기준으로 나눠 **해당 줄의 소스 문자열이 공백 제외 실제로 비어 있는지**를 직접 검사해 밑줄 여부를 결정하는 방식으로 교체(레이아웃 결과가 아니라 원본 데이터 기준 판정이라 더 안정적) |
| 회귀 위험 | 낮음 |
| 검출 기법 | 경계값 분석(줄 폭 0 근처) + 실사용자 보고 |

## PS-UI-23

| 항목 | 내용 |
|---|---|
| ID | PS-UI-23 |
| 상태 | 미수정 — SPEC-GAP(결함이 아니라 사용성 개선요청) |
| 심각도 | S4 Minor |
| 관련 요구사항 | SPEC-GAP — 초대코드 노출 위치에 대한 FR 없음 |
| 위치 | `lib/screens/community/group_detail_screen.dart:272-282`(멤버 초대 메뉴 항목), `lib/screens/community/invite_group_screen.dart` |
| 현상 | 본인이 만든 모임의 초대코드를 공유하려면 여러 단계를 거쳐야 해 접근성이 떨어진다 |
| 재현 절차 | 1. 모임 상세 화면 진입 2. 초대코드를 화면에서 바로 볼 수 있는지 확인 → 없음 3. 상단 메뉴(더보기) 시트를 열어야 "멤버 초대" 항목이 나오고, 그걸 눌러야 `InviteGroupScreen`에서 코드가 보임 |
| 기대 결과(사용자 요청) | 모임 상세 화면 자체에서 초대코드가 바로 보이거나 한 번의 탭으로 공유 가능해야 함 |
| 실제 결과 | 모임 상세 화면 → 메뉴 시트 → "멤버 초대" → 코드 확인, 총 2단계 진입 필요 |
| 근본 원인 | 초대코드 노출을 관리 메뉴(더보기 시트) 안 "멤버 초대" 액션 하나에만 연결해둔 설계. 결함이 아니라 설계 선택 |
| 수정 제안 | 모임 상세 화면 상단(모임 이름/설명 근처)에 초대코드를 짧게 표시 + 복사 아이콘을 상시 노출하는 안 제안. 채택 여부는 성헌 판단 필요(SPEC-GAP) |
| 회귀 위험 | 낮음 — UI 추가만, 기존 초대 플로우는 그대로 유지 가능 |
| 검출 기법 | 실사용자 보고(사용성) |

## PS-FLOW-09

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-09 |
| 상태 | **미확인 — 재현조건 불명확, 결함 여부 자체가 확정되지 않음(사용자도 "확실한 에러인지 애매하다"고 보고)** |
| 심각도 | 미판정 |
| 관련 요구사항 | SPEC 8-1 인증 상태 전이 |
| 위치 | `lib/main.dart:126-134`(`_RootGate`), `lib/providers/profile_provider.dart:5-18` |
| 현상 | 카카오/구글 로그인 후 온보딩(인적사항 입력·테마 선택) 단계가 스킵되고 바로 메인으로 들어가는 경우가 있었다고 보고됨 |
| 재현 절차 | ⚠️미확보 — 어떤 계정/순서로 재현됐는지 정보 없음 |
| 기대 결과 | 신규 사용자는 항상 온보딈을 거쳐야 함(SPEC 3장) |
| 실제 결과 | ⚠️확인 필요 |
| 근본 원인 | 로컬에 온보딈 완료 여부를 캐싱하는 로직은 없음(`profileProvider`는 항상 서버 `profiles` 테이블을 직접 조회, `profile_provider.dart:10-14`) — 즉 클라이언트 쪽 "가짜 스킵"은 코드상 근거가 없다. **가장 유력한 정상 동작 후보:** 카카오로 먼저 로그인해 프로필을 만든 뒤, 같은 이메일로 구글 로그인을 시도하면 Supabase가 두 로그인을 동일 사용자로 자동 연결(이메일 기준 identity linking)해 이미 존재하는 프로필을 그대로 사용하게 되어 온보딈이 "스킵된 것처럼" 보일 수 있음 — 이 경우는 결함이 아니라 정상 동작. 다른 계정/이메일 조합에서도 재현됐다면 별도 조사 필요 |
| 수정 제안 | 재현 조건(사용한 로그인 순서·이메일 동일 여부) 확보 후 재조사 |
| 회귀 위험 | — |
| 검출 기법 | 오류 추정(사용자 보고, 확정도 낮음) |

---

## 2026-08-06 — PS-FLOW-08 조사 중 파생 발견

## PS-FLOW-10

| 항목 | 내용 |
|---|---|
| ID | PS-FLOW-10 |
| 상태 | **✅ 수정 완료 + 실기기 검증 완료 (2026-08-06).** PS-FLOW-08 조사 중 같은 위젯에서 발견, 함께 수정(성헌 승인). 실기기(SM S911N)에서 Step3 → 시스템 뒤로가기 → **Step2 복귀 + 입력값("QAtest") 보존** 확인, 종료 다이얼로그 안 뜸 |
| 심각도 | S3 Major (플로우 자체는 진행 가능하나 입력 정정 수단이 없음) |
| 관련 요구사항 | SPEC-GAP (온보딩 단계 간 뒤로가기 요구사항 명문화 없음) |
| 위치 | `lib/screens/auth/widgets/profile_form.dart:491-501`(`OnboardingExitGuard.build`), 발현 화면 `lib/screens/auth/signup_step3_screen.dart:104,115` |
| 현상 | 온보딩 Step3(테마 선택)에서 뒤로가기를 누르면 Step2(프로필 입력)로 돌아가지 않고 **"앱을 종료할까요?" 다이얼로그**가 뜬다 — 이름을 잘못 입력했을 때 고치러 되돌아갈 방법이 없다 |
| 재현 절차 | 1. 구글/카카오 첫 로그인 → Step2에서 이름 입력 후 "다음" 2. Step3(테마 선택) 도달 3. AppBar 뒤로가기 또는 시스템 뒤로가기 |
| 기대 결과 | Step2로 복귀해 입력값을 수정할 수 있어야 함(Step3는 `Navigator.push`로 쌓인 화면이라 정상 pop 대상) |
| 실제 결과 | 종료 확인 다이얼로그 → "종료" 외 선택지는 화면 유지뿐, Step2 복귀 불가 |
| 근본 원인 | `OnboardingExitGuard`가 `PopScope(canPop: false)`를 **무조건** 걸어 라우트의 `popDisposition`을 `doNotPop`으로 강제한다. 이 가드는 "Signup2/3이 라우트 스택의 **루트**가 되는 경우"를 위해 설계됐는데(`profile_form.dart:442-443` 주석), 2026-07-28 이메일 가입 제거 시 종전의 `active` 스위치를 없애고 "항상 켜둔다"로 바꾸면서(`:445-446` 주석) **pop 가능한 Step3까지 과잉 차단**하게 됐다 |
| 수정 제안 | `canPop`을 `Navigator.of(context).canPop()`으로 조건화 — pop할 대상이 있으면(Step3) 정상 pop, 루트(Step2)에서만 종료 확인 |
| 실제 수정 (2026-08-06) | 위 제안대로 적용. 회귀 방지 테스트 2건 추가(`test/onboarding_escape_test.dart` — pop 가능 화면은 다이얼로그 없이 복귀 / 루트는 확인 다이얼로그 노출), 전부 PASS |
| 회귀 위험 | 낮음 — Step2(루트) 동작은 변경 없음. 단 온보딩 전 구간 실기기 회귀 필요 |
| 검출 기법 | 코드 리뷰 중 상태 전이 재검토 — PS-FLOW-08 조사 과정에서 `PopScope`의 `popDisposition` 오버라이드 동작을 추적하다 발견 |
