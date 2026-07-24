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
| 상태 | **✅ 수정 완료 (2026-07-25)** — `signup_step3_screen.dart` catch-all 추가, `flutter analyze` 기존과 동일 23 info만(신규 이슈 없음) |
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
| 상태 | **✅ 수정 완료 (2026-07-25)** — 공용 `OnboardingExitGuard`(`auth/widgets/profile_form.dart`) 신설, Signup2/3 양쪽에 적용. ARB 3키 추가(`onboardingExitTitle/Message/Confirm`), `flutter analyze` 신규 이슈 없음 |
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
