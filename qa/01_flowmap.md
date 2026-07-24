# QA 1단계 — 화면 전이 그래프 (01_flowmap.md)

> `qa/00_inventory.md` 1-1 근거로 작성. 간선에 트리거 액션 표기, 조건부 전이는 `|조건|`로 명시.
> 2단계(플로우 무결성 감사)는 이 그래프 + `docs/SPEC.md`를 기준으로 별도 세션에서 진행 예정 — 이 문서는 아직 판정을 포함하지 않는다.

```mermaid
graph TD
    Start([앱 실행]) --> RootGate[SCR-01 _RootGate]

    RootGate -->|세션 없음| Login[SCR-03 LoginScreen]
    RootGate -->|세션 O, profile null 카카오/구글 첫로그인| Signup2Oauth["SCR-04b SignupStep2
    (email/password=null)"]
    RootGate -->|세션 O, profile O| MainShell[MainShell 탭 셸]

    Login -->|이메일 로그인 성공| RootGate
    Login -->|카카오 버튼| KakaoOAuth[외부 브라우저 OAuth]
    Login -->|구글 버튼| GoogleOAuth[GoogleSignIn 계정선택]
    KakaoOAuth -->|딥링크 복귀 com.praystory://login-callback| RootGate
    GoogleOAuth -->|idToken 발급| RootGate
    Login -->|"회원가입" 링크| Signup1[SCR-04a SignupStep1]

    Signup1 -->|형식검증 통과, 다음| Signup2[SCR-04b SignupStep2]
    Signup1 -->|뒤로가기| Login

    Signup2 -->|이름 필수입력 통과, 다음| Signup3[SCR-04c SignupStep3]
    Signup2 -->|뒤로가기| Signup1
    Signup2Oauth -->|이름 필수입력 통과, 다음| Signup3Oauth["SCR-04c SignupStep3
    (email/password=null)"]

    Signup3 -->|"시작하기": signUp+profiles insert| RootGate
    Signup3 -->|뒤로가기 저장중 아니면| Signup2
    Signup3Oauth -->|"시작하기": profiles insert만, ref.invalidate profileProvider| RootGate

    MainShell -->|탭0 기본| Home[SCR-05 HomeScreen]
    MainShell -->|하단 탭바| Record[SCR-Rec RecordScreen]
    MainShell -->|하단 탭바| Community[SCR-Com CommunityScreen]
    MainShell -->|하단 탭바| Settings[SCR-10 SettingsScreen]
    MainShell -->|하단 FAB| WriteSheetNew["SCR-06 PrayerWriteScreen
    (신규, targetDate=selectedDate)"]

    Home -->|빈 페이지 탭 / 여백 탭| WriteSheetNew
    Home -->|기도 항목 탭| WriteSheetEdit["SCR-07 PrayerWriteScreen
    (수정, prayer=선택항목)"]
    Home -->|기도 항목 길게누르기 → 확인 다이얼로그 → 삭제| Home
    Home -->|"오늘" 링크| Home

    WriteSheetNew -->|저장 성공| Home
    WriteSheetNew -->|X 닫기 저장중 아니면| Home
    WriteSheetEdit -->|저장 성공| Home
    WriteSheetEdit -->|삭제 확인 → Undo스낵바| Home
    WriteSheetEdit -->|X 닫기| Home

    Record -->|달력 날짜 탭 미래아니면| Home
    Record -->|검색결과 탭 HistorySearchOverlay| Home
    Record -->|지난기록 행 탭| Home
    Record -->|달력 좌우화살표/스와이프| Record

    Community -->|"모임 만들기"| CreateGroup[CreateGroupScreen]
    Community -->|"초대 코드"| JoinGroup[JoinGroupScreen]
    Community -->|그룹 카드 탭| GroupDetail[GroupDetailScreen]

    CreateGroup -->|생성 성공, pop| Community
    CreateGroup -->|"코드로 참여" pushReplacement| JoinGroup
    CreateGroup -->|뒤로가기| Community
    JoinGroup -->|참여 성공, pop| Community
    JoinGroup -->|뒤로가기| Community

    GroupDetail -->|뒤로가기| Community
    GroupDetail -->|+FAB "편지쓰기"| LetterWrite["CommunityLetterWriteScreen
    (groupId 전달)"]
    GroupDetail -->|+FAB "공지작성" 방장만| NoticeWrite[NoticeWriteScreen]
    GroupDetail -->|+FAB "멤버초대"| Invite[InviteGroupScreen]
    GroupDetail -->|메뉴 "나가기"/"그룹삭제" 확인| Community
    GroupDetail -->|세그먼트탭 공지/서신/멤버| GroupDetail

    LetterWrite -->|전송 성공, pop| GroupDetail
    LetterWrite -->|뒤로가기| GroupDetail
    NoticeWrite -->|등록 성공, pop| GroupDetail
    NoticeWrite -->|뒤로가기| GroupDetail
    Invite -->|뒤로가기| GroupDetail

    Settings -->|"내 정보"| ProfileEdit[ProfileEditScreen]
    Settings -->|"앱 설정"| AppSettings[AppSettingsScreen]
    Settings -->|"피드백"| Feedback[FeedbackScreen]
    Settings -->|"계정"| Account[AccountScreen]

    ProfileEdit -->|저장 성공, pop| Settings
    ProfileEdit -->|뒤로가기| Settings
    AppSettings -->|"알림"| NotifSettings[NotificationSettingsScreen]
    AppSettings -->|테마/언어 바텀시트, 즉시반영| AppSettings
    AppSettings -->|뒤로가기| Settings
    NotifSettings -->|알람 추가/삭제/토글/시간변경| NotifSettings
    NotifSettings -->|뒤로가기| AppSettings
    Feedback -->|전송 성공, pop| Settings
    Feedback -->|뒤로가기| Settings
    Account -->|로그아웃 확인 → clearAll+signOut| RootGate
    Account -->|회원탈퇴 확인 → Edge Function+clearAll| RootGate
    Account -->|뒤로가기| Settings

    Orphan1["⚠️ GroupInfoScreen
    (고아 — push하는 곳 없음)"]
    Orphan2["⚠️ PrayForSomeoneScreen
    (고아 — push하는 곳 없음)"]
    Orphan3["⚠️ 커뮤니티 전체공개 편지 피드
    (communityLettersProvider — 쓰기만 되고
    보여주는 화면 없음)"]

    style Orphan1 fill:#552222,stroke:#ff5555
    style Orphan2 fill:#552222,stroke:#ff5555
    style Orphan3 fill:#552222,stroke:#ff5555
```

---

## 그래프에서 바로 드러나는 구조적 특징 (판정 아님, 2단계 입력용 메모)

1. **모든 "탈출" 경로가 결국 `RootGate`로 수렴한다.** 로그인 성공, 온보딩 완료, 로그아웃, 탈퇴 4가지 경우 전부 `RootGate` 재평가로 귀결 — 이 구조 자체는 일관적이나, 그 만큼 `RootGate`의 상태 판정 로직(세션 유무 → profile 유무) 하나가 전체 앱 진입의 단일 장애점이다. 2단계에서 이 게이트의 실패 모드(네트워크 끊김 상태에서 세션 판정이 어떻게 되는지 등)를 집중 점검할 필요.
2. **탭 전환은 라우트 스택에 안 쌓인다** (`AnimatedOpacity`+`IgnorePointer` 크로스페이드, `main.dart:184-199`). 즉 "기록→서신서(검색 결과 탭)→뒤로가기" 같은 흐름에서 시스템 뒤로가기가 예상과 다르게 동작할 수 있음 — `previousTabProvider`(`nav_provider.dart:6`)로 수동 스택을 흉내내고 있어(`main.dart:171-182`), 이 수동 스택 로직 자체가 2단계 F6(뒤로가기 복귀)·F11(이탈 후 복귀) 검증 대상.
3. **커뮤니티 서브트리(CreateGroup/JoinGroup/GroupDetail/…)는 순수 push/pop 스택**이라 표준적이나, 그 안에 고아 화면 2개(`GroupInfoScreen`, `PrayForSomeoneScreen`)가 그래프 밖에 붕 떠 있다 — 도달 경로가 없으므로 이 그래프에 실선으로 못 그림.
4. **"편지 작성" 노드가 3갈래 진입(그룹편지/전체공개/소중한이에게)을 갖는데 이탈 후 보여지는 화면이 갈라지지 않는다** — 그룹편지는 GroupDetail로 복귀해 바로 보이지만, 전체공개(`community`)로 쓴 편지는 되돌아갈 화면 자체가 없어 그래프상 "쓰고 나면 증발"하는 유일한 분기다.

---

---

# QA 2단계 — 플로우 무결성 감사 (2026-07-25)

> 사용자 확인 완료 후 진행. 1단계에서 찾은 고아기능(PrayForSomeoneScreen 등)은 사용자가 "일단 그대로 두고 개발은 여기서 마무리"로 확정 — 이번 2단계에선 그 항목들을 다시 건드리지 않고 **플로우 완주 가능성**만 본다.
> "버튼이 눌리는가"가 아니라 **"플로우가 끝까지 완주되는가"** 관점. 코드 근거는 1단계에서 이미 정독한 파일들 기준.

## 판정 요약표 (F1~F12)

| # | 플로우 | 판정 | 핵심 근거 |
|---|---|---|---|
| F1 | 최초실행→온보딩→가입→첫작성→저장 | **조건부** | 3단계 signUp/insert 중 네트워크예외 무응답(PS-FLOW-01), OAuth경로 뒤로가기 시 확인없이 앱종료(PS-FLOW-02) |
| F2 | 로그인(이메일/소셜)→홈진입 | 완주가능 | 에러 스낵바 처리 확인, 세션갱신 시 RootGate 자동전환 |
| F3 | 작성→저장→목록반영→상세조회 | 완주가능 | invalidate 정상, 신규모드 draft보호(B2) |
| F4 | 수정→저장→반영 | **조건부** | 수정모드는 draft 미적용 — 이탈 시 편집내용 유실(PS-FLOW-03, SPEC에 이미 스코프컷으로 기록된 사항 재확인) |
| F5 | 삭제→확인→목록반영→되돌리기 | 완주가능(발견성 이슈) | Undo 정상 동작, 단 홈에서 삭제 진입점이 길게누르기뿐이라 발견성 낮음(PS-FLOW-06) |
| F6 | 목록탐색→검색→상세진입→복귀 시 상태유지 | 완주가능(경미한 상태초기화) | 날짜/월 상태는 유지되나 검색창 자체는 결과선택 시 초기화(PS-FLOW-07, 의도된 설계로 보임) |
| F7 | 세션만료→재인증→원래작업 복귀 | **조건부(저빈도)** | 탭 위치·선택날짜는 ProviderScope가 루트라 세션전환에도 보존(PASS) — 단 작성 중 바텀시트는 RootGate 서브트리 통째 교체로 강제종료 가능성(PS-FLOW-04, 실제 만료 재현은 어려움) |
| F8 | 로그아웃→재로그인(이전사용자 데이터 잔존) | 완주가능(경미) | `LocalPrayerStore.clearAll()`로 평문 캐시/draft 삭제 확인(FR-007), 데이터 자체 크로스유저 노출 없음 — 단 선택탭/날짜 등 UI 위치 상태만 다음 로그인 사용자에게 이월(S4) |
| F9 | 회원탈퇴→데이터삭제→동일이메일 재가입 | 완주가능(일부 미실증) | `delete-account` Edge Function 정상동작 7단계에서 재확인(cascade 포함) — "동일 이메일 재가입" 자체는 이번 세션엔 실증 안 함(미확인) |
| F10 | 알림수신→탭→진입(종료/백그라운드/포그라운드) | 완주가능 | payload/커스텀 라우팅 없이 단순 실행만(FR-011 요구사항과 정확히 일치, 상태별 분기 자체가 없어 전부 동일 동작) |
| F11 | 작성중 이탈→복귀 | **조건부** | 신규모드는 800ms 디바운스 draft로 대부분 보호, 수정모드는 F4와 동일하게 미보호 |
| F12 | 설정변경→전역반영→재시작후유지 | 완주가능(콜드스타트 flash) | 영속 자체는 정상 — 단 테마/언어/알람 3개 provider 전부 "동기 기본값 + 비동기 _load() 재정의" 패턴이라 콜드스타트 첫 프레임에 잠깐 잘못된 값이 보일 수 있음(PS-FLOW-05) |

**요약: 12개 중 완전 PASS 6개, 조건부 4개, 경미한 흠 있지만 완주는 되는 것 2개. S1(크래시/데이터유실/타인노출)급은 없음. 전부 S3 이하.**

---

## 플로우별 상세

### F1 — 최초 실행 → 온보딩 → 가입 → 첫 기도문 작성 → 저장

| # | 사용자 행동 | 코드 위치 | 상태변화 | 성공 시 | 실패 시 | 판정 |
|---|---|---|---|---|---|---|
| 1 | 앱 최초 실행 | `main.dart:95-128`(`_RootGate`) | 세션 없음 확인 | LoginScreen | — | PASS |
| 2 | "회원가입"→Step1 이메일/비번/확인 | `signup_step1_screen.dart:36-61` | 클라이언트 정규식+길이검증만, 미가입 | push Step2 | 스낵바(형식오류) | PASS |
| 3 | Step2 프로필 입력→"다음" | `signup_step2_screen.dart:75-92` | 이름 필수만 검증 | push Step3 | 스낵바 | PASS |
| 4 | Step3 테마선택→"시작하기" | `signup_step3_screen.dart:62-110` | `signUp()`+`profiles.insert()`+테마저장 | popUntil(isFirst)→RootGate→MainShell | `on AuthException`/`on PostgrestException`만 catch | **⚠️ 아래 참조** |

**PS-FLOW-01 (S3):** `signup_step3_screen.dart:65-109`의 `_finish()`가 `on AuthException catch`, `on PostgrestException catch`만 잡고 **일반 예외(네트워크 끊김 등)는 안 잡음.** `finally`에서 `_isLoading=false`로 복원은 되니 버튼이 "먹통"은 아니지만, **사용자에게 아무 메시지도 없이 그냥 로딩만 풀리고 끝** — 왜 안 됐는지 모른 채로 다시 눌러야 함. 회원가입처럼 여러 단계 거쳐온 플로우 끝에서 원인불명 침묵 실패는 사용자 이탈로 이어지기 쉬움.
- 수정 제안: `} catch (e) { _snack(l.errSignupFailed); }` 캐치올 추가(다른 catch절 뒤에).

**PS-FLOW-02 (S3):** OAuth 온보딩 경로(`main.dart:118-121`)에서 `SignupStep2Screen`이 `Navigator.push`가 아니라 **`_RootGate.build()`가 직접 반환하는 위젯 = 사실상 라우트 스택의 루트**가 됨. 이 상태에서 시스템 뒤로가기(제스처/버튼)를 누르면 이 화면 위엔 pop할 라우트가 없어 **앱이 그대로 종료됨** — 확인 다이얼로그도, 안내도 없음. (테스트 결과 아님, 코드 구조 분석: `MainShell`엔 `PopScope`가 있는데(`main.dart:171`) 이 온보딩 화면들엔 없음.) 데이터 유실은 없음(카카오/구글 세션은 이미 서버에 살아있고, 재실행하면 RootGate가 다시 같은 온보딩 화면으로 보냄) — 사용자 경험만 나쁨.
- 수정 제안: Signup2/Signup3에 `PopScope`를 추가해 이 온보딩 경로(email==null && password==null)일 때만 "종료하시겠습니까?" 확인 또는 back 무시.

### F2 — 로그인 → 홈 진입
PASS. 이메일/카카오/구글 3경로 전부 성공 시 `authStateProvider` 갱신→`_RootGate` 자동전환, 실패 시 각각 스낵바(`login_screen.dart:37,49,67,77,80,98`). 카카오 취소(`GoogleSignInExceptionCode.canceled`)는 스낵바 없이 조용히 원복(`:76-78`) — 의도된 처리로 보임(사용자가 능동적으로 취소한 경우 에러 취급 안 함, 합리적).

### F3 — 기도문 작성 → 저장 → 목록 반영 → 상세 조회
PASS. `_save()`(`prayer_write_screen.dart:176-240`) 저장 성공 시 두 provider invalidate(`:209-210`) → 홈 화면 해당 날짜 목록에 즉시 반영. 신규모드는 draft 보호(B2). `Navigator.pop(context)` 직후 같은 `context`로 스낵바 호출(`:219-220`)하는 패턴은 Flutter에서 종종 쓰이는 방식이라 크래시 위험은 낮으나 **엄밀히는 pop 이후 context 사용 — 실기기에서 스낵바가 실제로 뜨는지/어디서 뜨는지 육안 확인 권장(미확인, 낮은 우선순위).**

### F4 — 기도문 수정 → 저장 → 반영
**PS-FLOW-03 (S3, 기존 스코프컷 재확인):** `prayer_write_screen.dart:130`(`_onChanged`)의 `if (_isNewMode) _scheduleDraftSave();` — **수정 모드는 draft 자동저장 대상에서 제외**(SPEC.md 13장 B2에 "신규작성만"으로 이미 명시된 의도적 결정). 즉 기존 기도문을 수정하다가(예: 전화옴, 실수로 뒤로가기) 저장 전에 이탈하면 **수정 중이던 내용은 그대로 유실**되고 원본(수정 전 내용)이 유지됨. 데이터가 없어지는 건 아니라 "유실"보다는 "수정분 미보존"이 정확한 표현. 이미 알려진 제한이라 새 결함은 아니지만, **F4/F11 관점에서 재확인해 문서화** — SPEC.md FR-005 "작성 중 이탈 시 데이터 유실 방지"의 적용범위가 수정모드까지인지 사용자 재확인 권장.

### F5 — 기도문 삭제 → 확인 → 목록 반영 → 되돌리기
완주 가능, Undo 정상 동작(공용 `showPrayerDeletedSnackBar`, 홈/작성화면 양쪽 경로 일관). **PS-FLOW-06 (S4, 1단계에서 이미 지적):** 홈 화면에서 삭제 진입점이 `_PrayerEntry`의 **길게 누르기 하나뿐**(`home_screen.dart:474`) — 스와이프 삭제나 아이콘 등 시각적 힌트가 전혀 없어 사용자가 삭제 기능 자체를 못 찾을 가능성.

### F6 — 목록 탐색 → 검색/필터 → 상세 진입 → 복귀 시 상태 유지
대체로 PASS. `selectedDateProvider`/`focusedMonthProvider`는 앱 전역 StateProvider라 탭 전환·복귀에도 유지됨(확인). **PS-FLOW-07 (S4):** `HistorySearchOverlay._selectPrayer()`(`history_search_overlay.dart:52-61`)가 결과 선택 시 `_controller.clear(); _onChanged('')`로 **검색창 자체를 비움** — 기록 탭으로 되돌아왔을 때 방금 검색했던 내용이 사라져 있음. 의도된 "깨끗한 상태로 복귀"일 수 있으나 사용자가 같은 검색어로 다른 결과를 더 보고 싶을 때 재입력해야 함.

### F7 — 세션 만료 → 재인증 → 원래 작업 복귀
탭 위치/선택 날짜 등 UI 상태는 `ProviderScope`가 `main.dart:38`에서 앱 최상단에 있어 `_RootGate`가 Login↔MainShell을 오가도 보존됨 — **이 부분은 PASS, 좋은 구조.**
**PS-FLOW-04 (S2/S3, 저빈도·미실증):** `_RootGate.build()`(`main.dart:105-127`)는 인증상태에 따라 `LoginScreen`/`SignupStep2Screen`/`MainShell` 중 **완전히 다른 위젯 서브트리를 반환** — 세션이 만료돼 이 분기가 바뀌면 그 서브트리에 속한 모든 것(열려있던 기도문 작성 바텀시트 포함, `showModalBottomSheet`도 그 컨텍스트의 Navigator를 쓰므로 함께 사라짐)이 통째로 사라진다. 즉 **작성 중 세션이 만료되면 경고 없이 작성 화면이 강제로 닫히고 로그인 화면으로 전환될 수 있음.** 신규모드는 800ms 디바운스 draft가 대부분 보호하지만, 수정모드는 F4와 동일하게 무방비. **실제 세션 만료가 앱 사용 중 일어나는 빈도는 낮음**(Supabase 리프레시 토큰 유효기간이 보통 김) — 재현이 어려워 이번 세션엔 실기기/강제 테스트 안 함, 구조 분석으로만 결론.

### F8 — 로그아웃 → 재로그인 (이전 사용자 데이터 잔존 여부)
핵심 보안 요건(FR-007)은 PASS: `account_screen.dart:24`(`LocalPrayerStore.clearAll()`)로 draft·오프라인캐시 평문 삭제 확인, 7단계 RLS 검증에서도 크로스유저 데이터 노출 없음 재확인. **경미(S4):** `shellTabProvider`/`selectedDateProvider` 등은 로그아웃 시 리셋 안 되므로, 같은 기기에서 곧바로 다른 계정으로 로그인하면 그 계정이 이전 사용자가 보던 탭/날짜 위치에서 시작함(데이터 자체는 안전, 위치만 이월) — 사용자 경험상 사소한 흠.

### F9 — 회원 탈퇴 → 데이터 삭제 → 동일 이메일 재가입
`delete-account` Edge Function은 7단계에서 실제 호출로 3회 검증 완료(성공). **"삭제 후 같은 이메일로 재가입 가능한지"는 이번 세션엔 별도로 실증 안 함(미확인)** — Supabase 기본 동작상 하드삭제 후 이메일 재사용은 통상 가능하나, 확정하려면 별도 테스트 필요.

### F10 — 알림 수신 → 탭 → 진입
PASS. `notification_service.dart` 전체에 `payload` 설정이나 `onDidReceiveNotificationResponse` 콜백이 없음(`initialize()` :19-44 확인) — SPEC FR-011 "탭 시 앱만 열리면 됨(딥링크 불필요)"과 정확히 일치. 앱종료/백그라운드/포그라운드 상태별 분기 코드 자체가 없어 세 상태 모두 동일하게 동작(OS 기본 동작에 위임).

### F11 — 작성 중 이탈(뒤로가기·홈버튼·전화수신) → 복귀
신규모드는 draft(B2)로 대부분 보호. **F4(PS-FLOW-03)와 동일 근본원인 — 수정모드는 무방비.** 홈버튼(백그라운드)·전화수신은 Flutter 위젯 dispose를 유발하지 않아(OS가 프로세스를 안 죽이는 한) 텍스트 유실 위험 낮음 — 저사양 기기의 메모리 회수로 인한 강제종료는 일반적 Flutter 앱 한계라 이 앱 고유 이슈 아님.

### F12 — 설정 변경(테마·알림·언어) → 전역 반영 → 재시작 후 유지
영속 자체는 전부 PASS(SharedPreferences 확인). **PS-FLOW-05 (S4, 반복 패턴 1건으로 통합 보고):** `themeModeProvider`(`settings_provider.dart:20`, `super(AppThemeMode.light)`), `languageProvider`(`:69`, `super(_detectDeviceLanguage())`), `prayerAlarmsProvider`(`notification_provider.dart:10`, `super([])`) **셋 다 "동기 기본값으로 즉시 시작 → 생성자에서 비동기 `_load()`가 나중에 실제 저장값으로 덮어씀"** 구조. `SharedPreferences.getInstance()`는 비동기라 최초 프레임은 항상 기본값(라이트모드/기기언어자동감지값/빈 알람목록)으로 그려지고, 로드 완료 후 실제 값으로 바뀜 — **콜드스타트 시 다크모드 사용자가 아주 짧게 라이트 화면을, 알림설정 화면을 성급히 열면 잠깐 "알람 없음" 빈 상태를 볼 수 있음.** 셀 수 있는 프레임 단위라 실사용 체감은 미미할 가능성 높으나, 세 곳 다 같은 패턴이라 한 번에 기록.

---

## 상태 전이도 검증 (2-4)

**인증 상태(미인증/인증/만료):** `_RootGate`가 유일한 판정 지점(`main.dart:105-127`) — 미인증→인증 전이는 정상(로그인/OAuth), 인증→미인증(만료·로그아웃)도 정상 처리되나 F7(PS-FLOW-04)에서 지적한 대로 그 위에 떠 있던 모달까지 함께 정리되는 부수효과 있음. "차단(banned)" 상태에 대응하는 코드나 스키마 플래그는 확인 안 됨(이 앱 스코프에 없는 개념으로 보임, SPEC에도 언급 없음 — 결함 아니라 범위 밖).

**기도문 문서 상태(신규/작성중/저장됨/수정중/삭제됨/동기화실패):**
- 불법 전이 `삭제됨→수정중` 시도 가능성: 삭제 시 화면이 즉시 `pop()`되고 목록에서도 제거돼 그 항목의 "수정" 진입점 자체가 사라짐 → **구조적으로 도달 불가, 안전(PASS).**
- Undo 후 새 id로 재insert되는 것(`restorePrayer`, `prayer_provider.dart:28-36`)이 "삭제됨→저장됨(신규취급)"에 해당 — 원본 id 재사용 안 하지만 `created_at`/`answered_at` 보존이라 사용자 입장에선 동일 기록으로 보임, 문제 없음.
- 강제종료 후 재시작 시 복원 상태: 신규작성 draft는 SharedPreferences라 프로세스 재시작에도 생존(B2 목적대로), 수정중이던 내용은 위에서 지적한 대로 미보존.

---

## 발견 결함 요약 (→ `qa/04_defects.md`에 정식 등록)

| ID | 심각도 | 한 줄 요약 |
|---|---|---|
| PS-FLOW-01 | S3 | 회원가입3단계 네트워크예외 캐치 안 해 무응답 |
| PS-FLOW-02 | S3 | OAuth온보딩 경로 뒤로가기 시 확인없이 앱종료 |
| PS-FLOW-03 | S3 | 기도문 수정모드는 draft 미적용(기존 스코프컷, 재확인) |
| PS-FLOW-04 | S2/S3(저빈도) | 세션만료 시 작성중 바텀시트 강제종료 가능성(구조분석, 미실증) |
| PS-FLOW-05 | S4 | 테마/언어/알람 3개 provider 콜드스타트 값 flash(반복패턴) |
| PS-FLOW-06 | S4 | 홈 삭제가 길게누르기뿐이라 발견성 낮음(1단계 재확인) |
| PS-FLOW-07 | S4 | 검색결과 선택 후 검색창 초기화(의도된 설계로 추정) |

## 다음 단계 메모

2단계 완료. 이번 세션은 1단계+7단계+7단계수정검증+2단계까지 진행 — 정식 순서(3단계 액션매트릭스 등)로 계속 갈지, 여기서 QA를 마무리하고 배포 트랙으로 넘어갈지 사용자 선택 대기.
