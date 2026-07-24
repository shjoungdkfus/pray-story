# QA 1단계 — 인벤토리 (00_inventory.md)

> 판정 없이 사실만 나열. 근거는 전부 `파일:라인`. 코드를 실제로 읽고 작성함(2026-07-25).
> 명세 대조 기준: `docs/SPEC.md` v0.3.

---

## 1-1. 라우트/화면 전수

이 앱은 `Navigator` 이름 라우트가 아니라 **탭 인덱스(`shellTabProvider`) + `MaterialPageRoute` push + 모달 바텀시트** 혼합 구조다. SCR-ID는 SPEC.md 4장 표기를 그대로 따르되, 코드에만 있고 SPEC에 없는 화면은 별도 표시.

### 게이트/셸

| 화면 | 위젯 | 파일:라인 | 진입 트리거 | 이탈 경로 |
|---|---|---|---|---|
| SCR-01 스플래시/루트게이트 | `_RootGate` | `main.dart:95` | 앱 실행(항상 `MaterialApp.home`) | 없음 — `authStateProvider`/`profileProvider` 값에 따라 매번 재평가되어 Login/온보딩/MainShell 중 하나를 그린다 |
| (SPEC 미기재) 메인 셸 | `MainShell` | `main.dart:130` | `_RootGate` data(세션 O, profile O) | `PopScope`(`main.dart:171`)로 시스템 뒤로가기 가로챔 — 기록/커뮤니티/설정 탭에서 뒤로가기 시 탭0(서신서)로, 탭0에서는 앱 종료 허용 |

### 탭 0~3 (MainShell 내부, `main.dart:139` `_screens` 배열)

| SCR-ID | 화면 | 파일:라인 | 비고 |
|---|---|---|---|
| SCR-05 | `HomeScreen` (서신서) | `home_screen.dart:17` | 탭0, 기본 선택 |
| SCR-Rec | `RecordScreen` (기도기록) | `record_screen.dart:13` | 탭1 |
| SCR-Com | `CommunityScreen` (커뮤니티) | `community_screen.dart:12` | 탭2 |
| SCR-10 | `SettingsScreen` (설정) | `settings_screen.dart:14` | 탭3 |

4개 화면 모두 `Stack` + `AnimatedOpacity` + `IgnorePointer` + `RepaintBoundary`로 항상 빌드된 채 유지된다(`main.dart:184-199`) — 진짜 라우트 전환이 아니라 크로스페이드. 탭 전환은 라우트 push/pop이 아니므로 시스템 뒤로가기 스택에 안 쌓인다.

### 인증/온보딩

| SCR-ID | 화면 | 파일:라인 | 진입 경로 | 이탈 경로 |
|---|---|---|---|---|
| SCR-03 | `LoginScreen` | `login_screen.dart:11` | `_RootGate`(세션 없음, `main.dart:112`) / 로그아웃·탈퇴 후 `popUntil(isFirst)` | "회원가입"→Step1(`login_screen.dart:191-195`) / 카카오·구글 버튼 → OAuth |
| SCR-04a | `SignupStep1Screen` | `signup_step1_screen.dart:10` | 로그인 "회원가입" 링크 | 뒤로가기(`maybePop`, `:75`) / "다음"→Step2(`:56-61`) — 형식검증만, 미가입 |
| SCR-04b | `SignupStep2Screen` | `signup_step2_screen.dart:10` | Step1 "다음" **또는** `_RootGate` OAuth 온보딩 분기(세션 O, profile null → `main.dart:120`, `email`/`password` 둘 다 null로 생성) | 뒤로가기 / "다음"→Step3(`:80-92`) |
| SCR-04c | `SignupStep3Screen` | `signup_step3_screen.dart:15` | Step2 "다음" | 뒤로가기(저장 중엔 차단, `:126`) / "시작하기"→`signUp`+profiles insert(이메일 경로) 또는 profiles insert만(OAuth 경로)→`popUntil(isFirst)`(`:96`) |

**OAuth 온보딩 진입 경로 특이사항:** `_RootGate`가 세션은 있지만 `profileProvider`가 `null`이면(카카오/구글 첫 로그인) Step1~2를 건너뛰고 곧바로 `SignupStep2Screen(email:null, password:null)`을 그린다(`main.dart:118-121`). 이 경로는 Step1을 절대 거치지 않는 유일한 진입점.

### 기도문 작성/수정 — 모달 바텀시트 (별도 라우트 아님)

| SCR-ID | 화면 | 파일:라인 | 열리는 지점(전부 나열) |
|---|---|---|---|
| SCR-06/07/08 | `PrayerWriteScreen` | `prayer_write_screen.dart:92` | ① MainShell 하단 FAB `_openWriteSheet`(`main.dart:145-159`, `targetDate` 전달, 신규) ② HomeScreen 빈 페이지 전체 탭(`home_screen.dart:185-198`, `_BookPage._openWriteSheet`, `targetDate` 전달) ③ HomeScreen 내용 있는 페이지의 빈 여백 탭(같은 핸들러, `:272`) ④ `_PrayerEntry` 탭(`home_screen.dart:420-433`, 수정모드 `prayer:` 전달) |

`widget.prayer == null` 이면 신규(draft 자동저장 대상), 아니면 수정(대상 아님) — 위젯 하나가 SCR-06/07/08 세 논리화면을 겸함.

### 검색 — 별도 라우트 아님, RecordScreen에 항상 고정

| 화면 | 파일:라인 | 비고 |
|---|---|---|
| SCR-09 `HistorySearchOverlay` | `history_search_overlay.dart:11` | `record_screen.dart:60`에서 `Column` 맨 아래 항상 렌더 — "열고 닫는" 화면이 아니라 기록 탭 진입 시 항상 존재하는 검색바+결과 슬라이드업 |

### 커뮤니티 서브 라우트 (`Navigator.push`)

| 화면 | 파일:라인 | 진입 트리거 | 이탈 경로 |
|---|---|---|---|
| `CreateGroupScreen` | `create_group_screen.dart:10` | `CommunityScreen` "모임 만들기"(`community_screen.dart:15-20,71-76`) / 빈 목록 CTA(`:225-268`) / `JoinGroupScreen`에서 pushReplacement 없음(반대 방향만 존재, 아래) | 뒤로가기 / 생성 성공 시 `pop()`(`:44`) — `CommunityScreen`이 `myGroupsProvider` invalidate |
| `JoinGroupScreen` | `join_group_screen.dart:8` | `CommunityScreen` "초대 코드"(`:22-27,79-86`) / `CreateGroupScreen` 하단 "코드로 참여" 링크(`create_group_screen.dart:238-255`, `pushReplacement`) | 뒤로가기 / 참여 성공 시 `pop()` |
| `GroupDetailScreen` | `group_detail_screen.dart:15` | `CommunityScreen` 그룹 카드 탭(`:29-34,108-111`) | 뒤로가기(`:107`) / 그룹 나가기·삭제 후 `pop()`(`:459`) |
| `InviteGroupScreen` | `invite_group_screen.dart:9` | `GroupDetailScreen` 추가시트 "멤버 초대"(`:271-280`) — `GroupInfoScreen`에서도 push하지만 그 화면 자체가 고아(아래 참조) | 뒤로가기만 |
| `NoticeWriteScreen` | `notice_write_screen.dart:9` | `GroupDetailScreen` 추가시트 "공지 작성"(방장만, `:257-268`) | 뒤로가기 / 등록 성공 시 `pop()` |
| `CommunityLetterWriteScreen` | `community_letter_write_screen.dart:9` | `GroupDetailScreen` 추가시트 "편지 쓰기"(`:241-256`, `groupId`/`groupName` 전달) — `PrayForSomeoneScreen`에서도 push하지만 그 화면 자체가 고아(아래) | 뒤로가기 / 전송 성공 시 `pop()` |

### ⚠️ 고아 화면 — 코드엔 있으나 어디서도 push되지 않음

| 화면 | 파일:라인 | 확인 방법 |
|---|---|---|
| `GroupInfoScreen` | `group_info_screen.dart:12` | `Grep GroupInfoScreen` → 자기 자신 정의(`:12,14`) 외 매치 0건. `GroupDetailScreen`은 같은 기능(이름변경/초대/멤버목록)을 자체 메뉴 시트로 대체 구현(`group_detail_screen.dart:287-360`) — **이 화면은 구버전 구현이 새 구현으로 대체된 뒤 삭제되지 않고 남은 것으로 보임.** `deleteGroup` 호출 지점이기도 해서(내부에 방장 전용 그룹 삭제 메뉴 포함) 코드 자체는 최신 RLS 정책과 호환되지만 진입 불가. |
| `PrayForSomeoneScreen` | `pray_for_someone_screen.dart:8` | `Grep PrayForSomeoneScreen` → 자기 정의 외 매치 0건. `CommunityScreen`에도, `GroupDetailScreen`에도 "소중한 이에게" 진입 버튼이 없음. `CommunityLetterWriteScreen`의 `recipientName` 파라미터·`letterOpeningHint` 프리필 로직(`community_letter_write_screen.dart:50-54`, `letterForRecipient` 표시 `:237-250`)은 이 화면을 통해서만 도달하는데 진입점이 없어 **"소중한 이에게" 기능 전체가 현재 UI에서 도달 불가.** |

### 설정 서브 라우트

| 화면 | 파일:라인 | 진입 | 이탈 |
|---|---|---|---|
| `ProfileEditScreen` | `profile_edit_screen.dart:13` | `SettingsScreen` "내 정보"(`:55`) | 뒤로가기 / 저장 성공 시 `pop()` |
| `AppSettingsScreen` | `app_settings_screen.dart:17` | `SettingsScreen` "앱 설정"(`:67`) | 뒤로가기(공용 `SettingsDetailScaffold`) |
| `NotificationSettingsScreen` | `notification_settings_screen.dart:12` | `AppSettingsScreen` "알림"(`:144-148`) | 뒤로가기 |
| `FeedbackScreen` | `feedback_screen.dart:30` | `SettingsScreen` "피드백"(`:79`) | 뒤로가기 / 전송 성공 시 `pop()` |
| `AccountScreen` | `account_screen.dart:11` | `SettingsScreen` "계정"(`:91`) | 뒤로가기 / 로그아웃·탈퇴 후 `popUntil(isFirst)` |

### 명세(SPEC.md 4장) ↔ 코드 양방향 차이

- SPEC에는 `SCR-Com | 커뮤니티 | 모임/서신` **한 줄**만 있음. 실제 코드는 이 한 줄 아래 최소 9개 세부 화면(CommunityScreen 본체 + 8개 서브라우트)으로 구성됨 → **SPEC-GAP**: 커뮤니티 세부 화면 목록이 명세에 없음.
- 코드에 있고 SPEC에 없는 화면 2개(위 고아 화면 표) — 명세에도 없고 도달 경로도 없으므로 굳이 SPEC에 추가할 필요는 없어 보이나, "왜 존재하는가"는 확인 필요.
- SPEC 4장의 SCR-04b 비고란 "N/부분" 표기가 실제로는 OAuth 온보딩 시 이 화면이 **유일한 진입점**이 되는 특수 분기(위 표 참고)까지는 설명하지 않음 — 정밀화 필요.

---

## 1-2. 인터랙티브 요소 전수조사

화면별로 의미 있는 인터랙션만 나열(순수 장식용 Container 탭 등 제외). 표기: 화면 / 요소 / 파일:라인 / 핸들러 동작 / 관련 FR.

### 로그인/회원가입

| 화면 | 요소 | 파일:라인 | 동작 |
|---|---|---|---|
| Login | 이메일/비번 입력 | `login_screen.dart:137-150` | `TextField`, 실시간 검증 없음(제출 시에만) |
| Login | 비번 표시 토글 아이콘 | `:141-150` | `setState(_obscure = !_obscure)` |
| Login | 로그인 버튼 | `:152-156` | `_login()` — 빈값이면 스낵바, 아니면 `signInWithPassword` |
| Login | 카카오 버튼 | `:160-166` | `_loginWithKakao()` — `signInWithOAuth` 외부 브라우저 |
| Login | 구글 버튼 | `:168-176` | `_loginWithGoogle()` — `GoogleSignIn.authenticate()` → `signInWithIdToken` |
| Login | "회원가입" 링크 | `:188-205` | push Step1 |
| Signup1 | 이메일/비번/확인 입력 | `:103-121` | `_next()`에서 정규식+길이(6+)+일치 검증(`:42-54`) |
| Signup1 | 다음 버튼 | `:177-203` | push Step2(값 전달, 미가입) |
| Signup2 | 이름/사진/교회/성별/연령대 행 | `profile_form.dart:84-145`(`ProfileFormFields`) | 각각 바텀시트/피커 오픈 |
| Signup2 | 다음 버튼 | `signup_step2_screen.dart:144-163` | 이름 필수 검증 후 push Step3 |
| Signup3 | 라이트/다크 카드 | `signup_step3_screen.dart:156-176` | 탭 시 `_selected` 갱신 + `AppColors.setMode()` 즉시 호출(전역 실시간 미리보기, `:116`) |
| Signup3 | 시작 버튼 | `:184-209` | `_finish()` — 이메일 경로 `signUp`+insert, OAuth 경로 insert만, 완료 후 `popUntil(isFirst)` |

### 홈(서신서)

| 요소 | 파일:라인 | 동작 |
|---|---|---|
| 글자크기 FAB | `home_screen.dart:46-55` | `FontSizePickerSheet` 바텀시트 |
| "오늘" 링크(다른 날짜 볼 때만) | `:78-94` | `selectedDateProvider` 오늘로 리셋 |
| 빈 페이지 전체 탭 | `:237-263` | 작성 시트 오픈(신규) |
| 내용 있는 페이지 여백 탭 | `:272-288` | 작성 시트 오픈(신규) — **주의: 항목 탭과 겹치는 영역 없음, `_PrayerEntry`가 자체 `GestureDetector`로 이벤트 소비** |
| 기도 항목 탭 | `:472` (`_PrayerEntry`) | 수정 시트 오픈 |
| 기도 항목 **길게 누르기** | `:474` | `_showDeleteDialog` → 확인 다이얼로그 → 삭제 + Undo 스낵바 — **스와이프 삭제(Dismissible) 없음, 길게 누르기가 유일한 삭제 진입점이라 발견성 낮음(1-2 관찰, 6단계 UX 심사 후보)** |

### 검색

| 요소 | 파일:라인 | 동작 |
|---|---|---|
| 검색 입력 | `history_search_overlay.dart:86-113` | `onChanged`→`searchQueryProvider` 갱신 + 애니메이션 펼침/접힘 |
| 결과 탭 | `:141-144` | `_selectPrayer` — 해당 날짜로 이동 + 탭0 전환 |

### 기도문 작성/수정

| 요소 | 파일:라인 | 동작 |
|---|---|---|
| 제목/본문 입력 | `prayer_write_screen.dart:370-416` | `onChanged`→`_onChanged()`(신규모드면 800ms 디바운스 draft 저장) |
| 닫기(X) 아이콘 | `:312-316` | 저장 중엔 `onPressed: null`(비활성) |
| 글자크기 아이콘 | `:330-333` | 바텀시트 |
| 저장/등록 버튼 | `:334-346` | `_canSave`(`:293-300`, 본문 비었거나 수정모드에서 변경 없으면 비활성)일 때만 활성 |
| 삭제 버튼(수정모드만) | `:347-361` | 확인 다이얼로그 → 삭제 + Undo 스낵바 |
| Undo 스낵바 액션 | `:32-46`(`showPrayerDeletedSnackBar`) | `restorePrayer` 재insert + invalidate, 실패 시 별도 스낵바 |

### 기도 기록 탭

| 요소 | 파일:라인 | 동작 |
|---|---|---|
| 달력 좌/우 화살표 | `prayer_calendar.dart:111-146` | `focusedMonthProvider` ±1개월, 미래월은 우측 화살표 비활성(`:139`) |
| 달력 PageView 스와이프 | `:171-190` | 페이지 변경 시 `focusedMonthProvider` 동기화(양방향) |
| 날짜 셀 탭 | `:402-409`(`_DayCell`) | 미래 날짜는 `onTap:null`, 아니면 탭0으로 이동+날짜 선택 |
| 지난 기록 행 탭 | `recent_records_section.dart:93-95` | 해당 날짜로 이동 |

**⚠️ 발견: 월간/주간 토글 UI가 현재 화면에 없음.** `record_screen.dart` 전체(1-1 참고)에 `statsViewModeProvider`를 **쓰는(set)** 코드가 전무함(`Grep statsViewModeProvider` 결과 `watch` 3건만, `.notifier).state =` 0건). `_WeekCalendar`(`prayer_calendar.dart:258-329`)와 `_computeStats`의 `weekOnly` 분기(`prayer_provider.dart:173-208`)는 전부 도달 불가한 죽은 코드 경로 — 항상 `StatsViewMode.month` 초기값으로 고정. `MonthTitlesSection`(응답 기도 제목 목록, `month_titles_section.dart:9`)도 `record_screen.dart`에서 import조차 되지 않아 렌더되지 않음(1-4에서 재확인).

### 커뮤니티

| 화면 | 요소 | 파일:라인 | 동작 |
|---|---|---|---|
| CommunityScreen | 모임 만들기/초대코드 버튼 | `community_screen.dart:70-86` | push Create/Join |
| CommunityScreen | 그룹 카드 탭 | `:108-111` | push GroupDetail |
| CreateGroup | 아이콘 선택 | `create_group_screen.dart:121-163` | `EmojiPicker` 풀피커(`group_icon_picker.dart`) |
| CreateGroup | 모임명 입력 + 만들기 버튼 | `:173-235` | `createGroup()` insert, 실패 시 에러 스낵바(**raw `e.toString()` 노출**, `:47-51` — 6단계 "개발자 문구 노출" 후보) |
| JoinGroup | 초대코드 입력 + 참여 버튼 | `join_group_screen.dart:92-141` | `joinGroupByCode()` — 이미 멤버면 조용히 성공 처리(`community_provider.dart:212`), 정원 초과 시 서버 트리거 예외 메시지 그대로 노출 |
| GroupDetail | 상단 메뉴(☰) | `:132-143,287-360` | 방장: 이름변경/설명수정/아이콘변경/멤버관리, 전원: 나가기 |
| GroupDetail | + FAB | `:224-232,234-284` | 편지쓰기/공지작성(방장)/멤버초대 시트 |
| GroupDetail | 공지 삭제(X) | `:551-558` | 방장만 노출, 확인 없이 즉시 삭제(`:489`) — **파괴적 액션인데 확인 다이얼로그 없음(6단계 후보)** |
| GroupDetail | 편지 삭제(X) | `:677-684` | 본인 편지만 노출, **확인 다이얼로그 있음**(`:598-625`, 공지 삭제와 비일관) |
| GroupDetail | "🙏 함께 기도" 칩 | `:794-828` | `toggleLetterPrayer` — 연타 방지 `_busy` 플래그(`:716,719-726`) |
| GroupDetail | 아바타 스택/칩 길게 누르기·탭 | `:796,830` | 참여자 목록 바텀시트 |
| GroupDetail | 멤버 내보내기 | `:1029-1036,956-973` | 방장만, 확인 다이얼로그 O |
| GroupInfoScreen | (고아 — 1-1 참조) | `group_info_screen.dart` | 도달 불가 |
| InviteGroup | 코드 탭(복사) | `invite_group_screen.dart:82-88` | 클립보드 복사 + 스낵바 |
| InviteGroup | 공유 버튼 | `:117-135` | `Share.share()` |
| NoticeWrite | 본문 입력 + 등록 | `notice_write_screen.dart:65-70,93-105` | 방장 전용(진입 자체가 방장만 가능) |
| CommunityLetterWrite | 공개범위 칩 | `:208-231,102-162` | private/그룹별/community 선택 |
| CommunityLetterWrite | 본문 입력 + 전송 | `:255-270,186-195` | `postCommunityLetter()` |
| PrayForSomeone | (고아 — 1-1 참조) | `pray_for_someone_screen.dart` | 도달 불가 |

### 설정 전반

| 화면 | 요소 | 파일:라인 | 동작 |
|---|---|---|---|
| Settings | 4개 그룹 타일 | `settings_screen.dart:48-94` | 각각 서브 라우트 push |
| ProfileEdit | 필드 5종 | `profile_edit_screen.dart` | Signup2와 동일 위젯 공유 |
| ProfileEdit | 저장 버튼 | `:171-196` | `upsert`, `on PostgrestException`만 catch(네트워크 예외는 미처리 — 5단계 엣지케이스 후보) |
| AppSettings | 알림 타일 | `app_settings_screen.dart:140-149` | push NotificationSettings |
| AppSettings | 테마/언어 타일 | `:156-167` | 바텀시트 라디오 선택, 선택 즉시 반영(확인 버튼 없음) |
| NotificationSettings | 알람 추가 버튼 | `notification_settings_screen.dart:128-148` | `showTimePicker` → 권한요청 → `addAlarm` |
| NotificationSettings | 알람 타일(시간탭/삭제/토글) | `:154-219`(`_AlarmTile`) | 시간탭=`showTimePicker`, 삭제=즉시(확인 없음), 토글=on 시 권한요청 |
| Feedback | 카테고리 칩 4종 | `feedback_screen.dart:129-140,220-256` | 단일 선택 |
| Feedback | 내용 입력(최대 1000자) | `:152-173` | `maxLength` 하드 제한, 초과 입력 불가(카운터 텍스트 숨김 `counterText`는 없고 기본 카운터 노출 여부 미확인) |
| Feedback | 전송 버튼 | `:177-202` | DB insert, `on PostgrestException`만 catch |
| Feedback | "메일로 보내기" 버튼 | `:204-214` | `url_launcher` mailto, DB전송과 **별개 경로**(둘 다 눌러도 서로 모름 — 중복전송 사용자 책임) |
| Account | 로그아웃 타일 | `account_screen.dart:126-133` | 확인 다이얼로그 → `LocalPrayerStore.clearAll()` → `signOut()` → `popUntil(isFirst)` |
| Account | 회원탈퇴 타일 | `:136-144` | 확인 다이얼로그(destructive 스타일) → Edge Function `delete-account` → 로컬 정리 → `popUntil` |

### ⚠️ 빈 콜백/TODO/도달불가 핸들러 — 별도 목록

| 항목 | 파일:라인 | 상태 |
|---|---|---|
| 프로필 사진 편집 | `signup_step2_screen.dart:47-49`, `profile_edit_screen.dart:55-57` | `_editPhoto()`가 "준비 중" 스낵바만 표시 — 의도된 스텁(미구현 명시), 버그 아님 |
| 카카오/구글 로그인 버튼(과거 스텁) | — | 현재는 실제 구현으로 교체 완료(2026-07-02), 스텁 없음 — 과거 기록과 혼동 주의 |
| `addTomorrowAlarm`/`cancelAlarm`/`hasAlarmForPrayer` | `notification_provider.dart:118,143,153` | 함수 자체는 완성돼 있으나 **호출하는 UI가 어디에도 없음**(1-4 참조) |
| `showNotificationPickerSheet` 전체(900줄 규모 위젯) | `notification_picker_sheet.dart:8` | 정의는 완성돼 있으나 **호출부 0건** — `Grep showNotificationPickerSheet` 결과 정의 외 매치 없음 |
| `MonthTitlesSection`/`answeredTitlesProvider` | `month_titles_section.dart:9`, `prayer_provider.dart:233` | 위젯 완성돼 있으나 `record_screen.dart`에서 import조차 안 됨 |
| `GroupInfoScreen`, `PrayForSomeoneScreen` | 1-1 참조 | 화면 자체가 고아 |
| `communityLettersProvider`(전체 공개 편지 피드) | `community_provider.dart:126` | **`ref.invalidate`(`community_letter_write_screen.dart:76`) 호출만 있고 `ref.watch`가 앱 전체에 0건** — "커뮤니티 전체공개" 편지를 쓸 수는 있는데(비공개범위 선택지에 있음) 그걸 목록으로 보여주는 화면이 존재하지 않음 |
| `'private'` 가시성 편지 | `community_letter_write_screen.dart:97,120,219` | 작성 시 선택 가능하고 DB엔 저장되며 본인은 RLS상 조회 가능(`community_letters_select_own`)하지만, **작성자 본인의 편지함/보관함 UI 자체가 없어** 쓴 뒤 다시 볼 방법이 없음 |
| `ProfileModel.birthdate` 필드 | `profile_model.dart:4,13,24-26` | JSON에서 파싱은 하지만 앱 어디서도 읽지 않음(`Grep \.birthdate` 결과 정의 외 0건) — `birth_year` 도입 이전 레거시로 추정 |

---

## 1-3. 화면 전이 그래프

`qa/01_flowmap.md` 참고.

---

## 1-4. Riverpod Provider 전수

| Provider | 타입 | 파일:라인 | autoDispose | 소비 위젯(대표) | 비고 |
|---|---|---|---|---|---|
| `supabaseProvider` | `Provider<SupabaseClient>` | `auth_provider.dart:4` | X | 거의 전 화면 | 앱 생명주기 내내 유지 |
| `authStateProvider` | `StreamProvider<AuthState>` | `:6` | X | `_RootGate`(`main.dart:107`) | |
| `currentUserProvider` | `Provider<User?>` | `:10` | X | 다수(홈/작성/커뮤니티/계정 등) | |
| `profileProvider` | `FutureProvider.autoDispose<ProfileModel?>` | `profile_provider.dart:5` | O | `_RootGate`, `HomeScreen`, `SettingsScreen` | signup_step3에서 `ref.invalidate`로 OAuth 온보딩 완료 트리거 |
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, AppThemeMode>` | `settings_provider.dart:42` | X(SharedPreferences 영속) | `main.dart`, `signup_step3`, `app_settings_screen` | |
| `languageProvider` | `StateNotifierProvider<LanguageNotifier, AppLanguage>` | `:91` | X | `main.dart`, `app_settings_screen` | 기기 언어 자동감지 + 수동 override |
| `fontSizeProvider` | `StateNotifierProvider<FontSizeNotifier, double>` | `font_size_provider.dart:24` | X | `home_screen`(`_PrayerEntry`), `prayer_write_screen`, `font_size_picker_sheet` | |
| `prayerAlarmsProvider` | `StateNotifierProvider<PrayerAlarmsNotifier, List<PrayerAlarm>>` | `notification_provider.dart:78` | X | `notification_settings_screen` | |
| `tomorrowAlarmsProvider` | `StateNotifierProvider<TomorrowAlarmsNotifier, List<TomorrowPrayerAlarm>>` | `:158` | X | **소비 위젯 없음** | 고아 provider(1-2 참조) |
| `isOfflineProvider` | `StateProvider<bool>` | `prayer_provider.dart:10` | X | `home_screen`(`_OfflineBanner`) | `_markOffline` 헬퍼가 `Future.microtask`로만 write |
| `selectedDateProvider` | `StateProvider<DateTime>` | `:41` | X | `home_screen`, `main.dart`, `history_search_overlay`, `record_screen` | |
| `prayersForDateProvider(date)` | `FutureProvider.autoDispose.family<List<PrayerModel>, DateTime>` | `:43` | O | `home_screen`(`_BookPage`) | 실패 시 캐시 폴백(B3) |
| `searchQueryProvider` | `StateProvider<String>` | `:81` | X | `history_search_overlay` | |
| `searchResultsProvider` | `FutureProvider.autoDispose<List<PrayerModel>>` | `:83` | O | `history_search_overlay` | 최대 20건 |
| `statsViewModeProvider` | `StateProvider<StatsViewMode>` | `:106` | X | `prayer_calendar`, `prayerStatsProvider`, `answeredTitlesProvider` | **`watch`만 3건, `write` 0건 — 사실상 상수(1-2 참조)** |
| `focusedMonthProvider` | `StateProvider<DateTime>` | `:109` | X | `record_screen`, `prayer_calendar`, 통계류 provider | |
| `monthPrayersProvider(month)` | `FutureProvider.autoDispose.family<List<PrayerModel>, DateTime>` | `:114` | O | `prayer_calendar`(`_CalendarGrid`), 통계 파생 provider | 캐시 폴백(B3) 대상 |
| `prayerStatsProvider` | `Provider.autoDispose<AsyncValue<PrayerStats>>` | `:210` | O | `stats_summary_row`, `prayer_calendar`(`_WeekCalendar`) | `monthPrayersProvider` 파생 |
| `recentPrayersProvider` | `Provider.autoDispose<AsyncValue<List<PrayerModel>>>` | `:222` | O | `recent_records_section` | `monthPrayersProvider` 재사용, 추가쿼리 없음 |
| `answeredTitlesProvider` | `Provider.autoDispose<AsyncValue<List<PrayerModel>>>` | `:233` | O | **`month_titles_section`만 소비하는데 그 위젯이 import 안 됨 → 사실상 고아** | |
| `selectedCategoryProvider` | `StateProvider<String>` | `community_provider.dart:8` | X | **소비 위젯 0건** — `Grep selectedCategoryProvider` 결과 정의 1건뿐 | 고아 provider |
| `myGroupsProvider` | `FutureProvider.autoDispose<List<CommunityGroup>>` | `:12` | O | `community_screen`, 여러 그룹 CRUD 후 invalidate | |
| `groupMembersProvider(groupId)` | `FutureProvider.autoDispose.family` | `:50` | O | `group_detail_screen`(`_MemberList`), `group_info_screen`(고아 화면이라 사실상 미소비) | |
| `groupNoticesProvider(groupId)` | `FutureProvider.autoDispose.family` | `:72` | O | `group_detail_screen`(`_NoticeList`) | |
| `letterPrayerProvider(letterId)` | `FutureProvider.autoDispose.family` | `:94` | O | `group_detail_screen`(`_LetterCard`) | RLS `USING(true)` — 7단계 확인 대상 |
| `communityLettersProvider` | `FutureProvider.autoDispose<List<CommunityLetter>>` | `:126` | O | **`invalidate`만 있고 `watch` 0건 — 사실상 고아(1-2 참조)** | |
| `groupLettersProvider(groupId)` | `FutureProvider.autoDispose.family` | `:140` | O | `group_detail_screen`(`_LetterList`) | |

**요약:** 정의된 provider 24개 중 **4개가 사실상 고아**(`tomorrowAlarmsProvider`, `answeredTitlesProvider`, `selectedCategoryProvider`, `communityLettersProvider`) — 소비 위젯이 없거나 invalidate만 있고 watch가 없음. `statsViewModeProvider`는 고아는 아니나 write 경로가 없어 상수처럼 동작.

---

## 1-5. Supabase 접근 지점 전수

| 테이블/함수 | 연산 | 파일:라인 | 필터 조건 | 실시간 구독 |
|---|---|---|---|---|
| `profiles` | select(단건) | `profile_provider.dart:10-14` | `.eq('id', user.id)` | X |
| `profiles` | select(다건, 이름 조회) | `community_provider.dart:40` | `.inFilter('id', ids)` | X |
| `profiles` | insert | `signup_step3_screen.dart:80-86` | — | X |
| `profiles` | upsert | `profile_edit_screen.dart:93-99` | `id` 포함 upsert | X |
| `prayers` | select(날짜별) | `prayer_provider.dart:55-61` | `.eq('user_id',..)` + `.gte/.lt('created_at',..)` | X |
| `prayers` | select(월별) | `:126-132` | 동일 패턴, 월 범위 | X |
| `prayers` | select(검색) | `:91-97` | `.eq('user_id',..)` + `.or(ilike title/content)` + `.limit(20)` | X |
| `prayers` | insert(신규) | `prayer_write_screen.dart:201-206` | — | X |
| `prayers` | insert(Undo 복원) | `prayer_provider.dart:29-36`(`restorePrayer`) | created_at/answered_at 보존 | X |
| `prayers` | update(수정) | `prayer_write_screen.dart:187-191` | `.eq('id',..)` | X |
| `prayers` | delete | `prayer_write_screen.dart:255`, `home_screen.dart:448` | `.eq('id',..)` | X |
| `community_groups` | select(전체, 초대코드용) | `community_provider.dart:26-30,198-202` | `.inFilter`/`.eq('invite_code',..)` | X |
| `community_groups` | insert | `:171-181` | — | X |
| `community_groups` | update(이름/설명/아이콘) | `:300-322` | `.eq('id',..)` | X |
| `community_groups` | delete | `:292-298`(`deleteGroup`) | `.eq('id',..)` — 관련 `group_members`/`community_letters`도 명시적으로 먼저 삭제, `group_notices`는 **DB `ON DELETE CASCADE`로 자동 정리**(`supabase_sql/community_v2.sql:12`, 앱 코드가 안 지워도 안전 — 확인 완료) | X |
| `group_members` | select(내 그룹 id) | `community_provider.dart:17-20` | `.eq('user_id',..)` | X |
| `group_members` | select(멤버 목록) | `:54-58` | `.eq('group_id',..)` | X |
| `group_members` | select(중복참여 체크/정원계산) | `:206-217` | `.eq('group_id',..)`+`.eq('user_id',..)` | X |
| `group_members` | insert(생성 시 owner, 참여 시 member) | `:185-189,223-227` | — | 정원 초과 시 DB 트리거 예외(`rls_fixes.sql:28-50`) |
| `group_members` | delete(탈퇴) | `:285-289`(`leaveGroup`) | `.eq('group_id',..)`+`.eq('user_id',..)` | X |
| `group_members` | delete(방장이 내보냄) | `:325-332`(`removeMember`) | 동일 — RLS `group_members_delete_by_owner` 필요(적용 완료 확인, `rls_fixes.sql`) | X |
| `group_notices` | select | `:76-80` | `.eq('group_id',..)` | X |
| `group_notices` | insert | `:336-344` | — | X |
| `group_notices` | delete | `:346-349` | `.eq('id',..)` — RLS로 방장만 허용 | X |
| `community_letters` | select(전체공개) | `:130-135` | `.eq('visibility','community')`+`.limit(50)` | X — **이 provider 자체가 미소비(1-4)** |
| `community_letters` | select(그룹별) | `:144-149` | `.eq('group_id',..)`+`.limit(50)` | X |
| `community_letters` | insert | `:270-278` | — | X |
| `community_letters` | delete | `:353-355` | `.eq('id',..)` — RLS로 본인만 허용 | X |
| `letter_prayers` | select(내가 눌렀는지) | `:365-369` | `.eq('letter_id',..)`+`.eq('user_id',..)` | X |
| `letter_prayers` | select(중보 목록) | `:99-103` | `.eq('letter_id',..)` — **RLS `USING(true)`라 그룹/비공개 스코프 없이 letter_id만 알면 누구나 조회 가능(7단계 확인 대상)** | X |
| `letter_prayers` | insert/delete(토글) | `:372-384` | `.eq`두 조건 조합 | X |
| `feedback` | insert | `feedback_screen.dart:61-67` | — | X |
| `functions.invoke('delete-account')` | Edge Function 호출 | `account_screen.dart:48` | — | — |

**표에 없는 것(미확인):** `prayers`/`profiles`/`feedback` 테이블의 RLS 정책 원문이 `supabase_sql/`에 없음(대시보드에서 직접 설정된 것으로 추정, SPEC.md 7-1도 "실증 필요"로 표시) — **7단계(보안 검증) 진행 시 Management API로 `pg_policies` 직접 조회해서 확인 필요.**

---

## 참고 — 자동화 테스트 현황

`test/widget_test.dart`(`:1-7`)는 Flutter 기본 템플릿의 placeholder 1건(`expect(true, isTrue)`)뿐 — 실질적 테스트 0건. `integration_test/` 디렉터리 자체가 없음.
