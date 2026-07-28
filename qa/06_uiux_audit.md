# QA 6단계 — UI/UX 심사 (06_uiux_audit.md)

> 기준: `docs/PRAYSTORY_QA_PROMPT_v2.md` H절(6단계) 9개 항목 / Material 3·Android 플랫폼 컨벤션.
> 원칙: 취향이 아니라 **관례 위반과 혼란 유발 지점**만. 모든 판정에 `파일:라인` 근거. 확인 못 한 건 "미확인(사유)".
>
> | 항목 | 내용 |
> |---|---|
> | 수행일 | 2026-07-26 |
> | 범위 | `lib/` 전 화면·위젯 정적 코드 리뷰 (1단계 인벤토리 기준 도달 가능한 화면 전체) |
> | 방법 | 코드 정독 + WCAG 대비비 수치 계산(스크립트) + git 이력 대조 + ARB 키 정합성 검사 |
> | **실기기 조작** | **하지 않음** — 사용자 지시로 1단계(정적)만 수행. 실기기 확인 필요 항목은 §11에 별도 목록 |
> | 신규 결함 | 17건 (S3 10 / S4 7) — `qa/04_defects.md` PS-UI-02 ~ PS-UI-18 |
> | SPEC-GAP | 3건 (§10, 성헌 판정 대기) |
>
> ⚠️ **6단계 프롬프트의 다크모드 기준색(`#121624` 배경 + `#D46A55` 액센트)은 현재 코드와 다르다.**
> 실제 팔레트는 `lib/core/constants/app_colors.dart` 기준 다크 배경 `#000000` / 액센트 `#4D4D4D`(라이트·다크 공통)이다.
> 본 심사는 **코드의 실제 값**으로 계산했다.

---

## 0. 현재 팔레트 대비비 전수 계산 (WCAG 2.1)

`app_colors.dart:10-29` 값 그대로 계산. 기준: 일반 텍스트 AA **4.5:1**, UI 컴포넌트·굵은 큰글씨 **3:1**.

### 라이트 모드

| 전경 \ 배경 | background `#FFFFFF` | card `#F8F4EC` | bottomBar `#EFE6D0` |
|---|---|---|---|
| textPrimary `#150A02` | 19.51 ✅ | 17.79 ✅ | 15.70 ✅ |
| **textHint `#9C8A7A`** | **3.32 ❌** | **3.02 ❌** | **2.67 ❌** |
| accent `#4D4D4D` | 8.45 ✅ | 7.71 ✅ | 6.80 ✅ |
| calendarMark `#4D4D4D` | 8.45 ✅ | 7.71 ✅ | 6.80 ✅ |
| settingsIcon `#4D4D4D` | 8.45 ✅ | 7.71 ✅ | 6.80 ✅ |

### 다크 모드

| 전경 \ 배경 | background `#000000` | card `#242424` | bottomBar `#121212` |
|---|---|---|---|
| textPrimary `#D9D4CC` | 14.24 ✅ | 10.53 ✅ | 12.70 ✅ |
| textHint `#8F897F` | 6.05 ✅ | **4.47 ❌**(경계) | 5.40 ✅ |
| **accent `#4D4D4D`** | **2.48 ❌** | **1.84 ❌** | **2.22 ❌** |
| calendarMark `#B5AFA3` | 9.63 ✅ | 7.12 ✅ | 8.59 ✅ |
| settingsIcon `#8F897F` | 6.05 ✅ | **4.47 ❌**(경계) | 5.40 ✅ |

### 고정색(테마 무관)

| 조합 | 대비 | AA(4.5) | UI(3.0) |
|---|---|---|---|
| danger `#C0392B` on 라이트 card | 4.96 | ✅ | ✅ |
| **danger `#C0392B` on 다크 card** | **2.85** | ❌ | ❌ |
| **`Colors.red` `#F44336` on 라이트 card** | **3.36** | ❌ | ✅ |
| **`Colors.red` `#F44336` on 다크 card** | **4.22** | ❌ | ✅ |
| **아바타 이니셜 흰글씨 on `#D9C9A8`** | **1.63** | ❌ | ❌ |
| 아바타 이니셜 흰글씨 on `#B07A6A` | 3.60 | ❌ | ✅ |
| **FAB `#000000` vs 다크 bottomBar `#121212`** | **1.12** | ❌ | ❌ |
| FAB `#000000` vs 라이트 bottomBar | 16.90 | ✅ | ✅ |
| FAB 위 흰 `+` 아이콘 | 21.00 | ✅ | ✅ |
| **미래날짜 `#AA9880` on 라이트 card** | **2.55** | ❌ | ❌ |
| 미래날짜 `#AA9880` on 다크 background | 7.51 | ✅ | ✅ |
| 카카오 `#191600` on `#FEE500` | 14.20 | ✅ | ✅ |
| 구글 `#1F1F1F` on `#FFFFFF` | 16.48 | ✅ | ✅ |
| **[다크] 저장성공 스낵바 본문 `#000000` on accent** | **2.48** | ❌ | ❌ |
| [라이트] 저장성공 스낵바 본문 `#FFFFFF` on accent | 8.45 | ✅ | ✅ |

**핵심:** `accent`(`#4D4D4D`)가 라이트·다크 **동일 고정**(`app_colors.dart:21` 주석 "라이트·다크 동일")인데,
다크 배경이 `#000000`/`#242424`라서 **전경색으로 쓰는 순간 전부 AA 미달(1.84~2.48:1)**이 된다.
`calendarMark`(`:23`)와 `settingsIcon`(`:25`)은 같은 이유로 다크에서 밝게 분기해 뒀는데 **`accent`만 분기가 없다.**
→ **PS-UI-02**

---

## 1. 4상태(Loading / Empty / Error / Success) 존재 여부

| 화면 | Loading | Empty | Error | 근거 / 판정 |
|---|---|---|---|---|
| **홈(서신서) SCR-05** | ❌ **빈 화면** | ✅ 안내문+탭 CTA | ❌ **빈 화면·재시도 없음** | `home_screen.dart:232-233` `loading:`·`error:` 둘 다 `SizedBox.shrink()` → **PS-UI-03** |
| 기록 — 통계카드 | ◑ 이전값 유지 | ◑ `0일/0회` | ❌ **에러도 `0`으로 표시** | `stats_summary_row.dart:24-27` `whenOrNull(data:)`만 → 실패와 "기록 0건" 구분 불가 → **PS-UI-09** |
| 기록 — 달력 | ◑ 무표시 | ✅ 마크 없음(자연스러움) | ◑ 무표시 | `prayer_calendar.dart:217-223` `whenOrNull ?? {}` — 조용한 폴백이나 달력 특성상 수용 가능 |
| 기록 — 지난기록 | ✅ 스피너 | ❌ **통째로 사라짐** | ◑ 빨간 원문 텍스트 | `recent_records_section.dart:21-31` → **PS-UI-09**, 에러문구는 **PS-UI-05** |
| 검색 | ✅ 이전결과 유지 | ❌ **0건이면 아무것도 안 뜸** | ✅ `searchError`(PS-CRUD-04 수정분) | `history_search_overlay.dart:144` → **PS-UI-09** |
| 커뮤니티 목록 | ✅ 스피너 | ✅ `_EmptyGroups` + CTA | ◑ 원문 노출·재시도 없음 | `community_screen.dart:100-118` — **앱 내 최상 구현** |
| 그룹상세 공지/편지/멤버 | ✅ 스피너 | ✅ `_EmptyState` | ✅ 전용 에러문구 | `group_detail_screen.dart:473-529, 611-664, 975-1008` — 공지 에러는 전용 카피(`:525-529`) ✅ |
| 알림설정 | — | ✅ 아이콘+문구 | — | `notification_settings_screen.dart:91-108` (추가 버튼이 바로 아래 노출) |
| 작성/수정 | ❌ **인디케이터 없음** | ✅ 힌트텍스트 | ✅ 스낵바 | `prayer_write_screen.dart:351-359` 저장 중 표시 없음 → **PS-UI-15** |
| 로그인/가입1~3 | ✅ 버튼 내 스피너 | — | ✅ 스낵바 | `login_screen.dart:265-271`, `signup_step3_screen.dart:200-206` ✅ |

### 재시도 버튼: **앱 전역 0건**

`grep -rni "retry|재시도|다시 시도" lib/` → **Dart 코드에 재시도 컨트롤 0개.**
ARB 문구 7건이 "다시 시도해주세요"라고 **말만 하고**, 실제로 다시 시도할 버튼은 어디에도 없다.
`.when(error:)` 11곳 전부 정적 텍스트만 렌더한다. 6단계 요구사항("Error에 재시도 버튼") **미충족** → **PS-UI-06**

---

## 2. 일관성 (같은 의미 = 같은 라벨·색·위치인가)

### 2-1. 파괴적 동작 색상 — **3가지가 혼용** ❌

| 위치 | 사용 색 | 대비(라이트/다크) |
|---|---|---|
| 기도문 삭제 확인 (`prayer_write_screen.dart:82`) | **`Colors.red` `#F44336`** | 3.36 ❌ / 4.22 ❌ |
| 편지·모임 삭제 확인 (`group_detail_screen.dart:511,649`) | `AppColors.danger` `#C0392B` | 4.96 ✅ / 2.85 ❌ |
| 탈퇴 확인 다이얼로그 (`account_screen.dart:108`) | `AppColors.danger` | 4.96 ✅ / 2.85 ❌ |
| 멤버 내보내기 확인 (`group_detail_screen.dart:994`) | **`AppColors.accent`(회색)** | 7.71 ✅ / 1.84 ❌ |
| 설정 타일 destructive (`settings_kit.dart:134-135`) | **`AppColors.accent`(회색)** | — |

팔레트에 `danger`(`app_colors.dart:29`, 주석 "파괴적 동작(회원탈퇴 등) 강조")를 **일부러 정의해 놓고 3곳 중 1곳에서만 쓴다.**

### 2-2. 회원탈퇴 타일이 로그아웃 타일과 시각적으로 동일 ❌

`account_screen.dart:137-142`가 `destructive: true`를 **넘기지 않는다.**
`SettingsTile.destructive`(`settings_kit.dart:116,128,134`)는 **앱 전체에서 한 번도 `true`로 호출되지 않는 죽은 파라미터**다.
→ FR-008(즉시 완전삭제, 유예 없음)인 회원탈퇴가 로그아웃과 같은 회색 타일로 보인다. → **PS-UI-04**

### 2-3. 로딩 스피너 색 불일치

- 대부분: `CircularProgressIndicator(color: AppColors.accent)` (9곳)
- `recent_records_section.dart:23`: **색 미지정** → `ColorScheme.fromSeed(seedColor: #000000)`(`main.dart:48-51`)가 만든 테마색이 튀어나옴

### 2-4. 커밋 버튼 라벨 — 같은 동작에 8가지 표기

`buttonSave`"저장" / `writeSubmitOther`"저장하기" / `writeSubmitToday`"기록하기" / `writeSubmitEdit`"수정" /
`profileEditButton`"수정하기" / `buttonPost`"등록" / `buttonDone`"완료" / `feedbackSendButton`"보내기"

삭제 계열도 `buttonDelete`"삭제" vs `letterDeleteButton`/`noticeDeleteButton`"삭제하기"로 갈린다.
("기록하기" 같은 서신 은유는 의도된 것으로 보이나, **저장/저장하기·수정/수정하기 차이는 근거 없음**) → **PS-UI-16**

### 2-5. 삭제 확인 다이얼로그 유무

| 대상 | 확인 | 근거 |
|---|---|---|
| 기도문 | ✅ + Undo 스낵바 | `prayer_write_screen.dart:51-90`, B1 |
| 편지 | ✅ | `group_detail_screen.dart:627-654` |
| 공지 | ✅ (PS-ACT-01 수정분) | `group_detail_screen.dart:489-519` |
| 멤버 내보내기 | ✅ | `group_detail_screen.dart:986-997` |
| **알람** | ❌ 즉시 삭제 | `notification_settings_screen.dart:125-127` → §10 SG-03(판정 요청) |

---

## 3. 피드백 (모든 액션에 0.1초 내 시각 반응)

| 항목 | 결과 |
|---|---|
| `GestureDetector`(리플 없음) | **23곳** |
| `InkWell`/`Material`(리플 있음) | 9곳 |

리플 없는 주요 탭 대상 — **하단 중앙 FAB**(`main.dart:245-256`), 기도문 항목 탭/롱프레스(`home_screen.dart:472-475`),
달력 날짜 셀(`prayer_calendar.dart:402-409`), 커뮤니티 액션버튼·모임카드(`community_screen.dart:135,174`),
테마 미리보기 카드(`signup_step3_screen.dart:247`), 홈 "오늘로"(`home_screen.dart:80`).

특히 **하단 FAB은 앱의 대표 액션인데 `Container`+`GestureDetector`라 눌림 표현이 전혀 없다.**
바로 옆 탭 아이콘들은 `InkWell`(`main.dart:301`)이라 리플이 있어 **같은 바 안에서 반응이 갈린다.**

설정 타일은 `InkWell`이지만 splash가 `accent.withOpacity(0.06)`(`settings_kit.dart:141-142`)라
다크에서 `#4D4D4D` 6%가 `#242424` 위에 얹히는 꼴 → **사실상 안 보임.** → **PS-UI-12**

---

## 4. 내비게이션

| 항목 | 판정 |
|---|---|
| 탭 뒤로가기 | ✅ `main.dart:184-195` PopScope — 탭1~3 → 탭0, 탭0에서 종료. 예측 가능 |
| 기록→홈 이동 후 뒤로가기 | ✅ `previousTabProvider`로 기록탭 복귀(`record_screen.dart:16-20`) |
| 온보딩 뒤로가기 | ✅ PS-FLOW-02 수정분(`OnboardingExitGuard`) 적용 |
| 설정 상세 | ✅ `SettingsDetailScaffold` 통일된 뒤로가기 |
| 작성 시트 | ✅ 모달 바텀시트(0.95h) — 작성 흐름에 적절 |
| **홈에서 다른 날짜로 이동** | ⚠️ **직접 수단 없음** — §10 SG-01 |
| **비밀번호 재설정** | ✅ 2026-07-28 구현 완료(§10 SG-02) — `password_reset_screen.dart`, 실기기 검증 전 |
| 중복 이메일 가입 | ❌ 3단계까지 다 채운 뒤에야 검출 → **PS-UI-18** |

- **홈 날짜 이동:** `home_screen.dart` 전체에 `PageView`/`onHorizontalDrag`/날짜 피커가 없다.
  git 이력상 `PageView`는 `c9ff357`("UI 대규모 리팩토링")에서, `CupertinoDatePicker`는 그 이후 제거됨 — **의도적 리팩토링**으로 보이나
  현재 홈에서 다른 날짜로 가려면 기록탭 달력을 경유해야 한다. "오늘로"(`:77-94`)는 오늘이 아닐 때만 뜬다.
- **중복 이메일:** `signup_step1_screen.dart:36-61`은 형식 검증만 하고 서버 조회를 안 한다.
  실제 `signUp()`은 `signup_step3_screen.dart:71`에서 최초 호출 → `errAlreadyRegistered`(`:100-102`)가 3단계에서 뜨고,
  자동으로 1단계로 돌려보내지 않아 사용자가 뒤로 2번 눌러 재입력해야 한다.

---

## 5. 문구 (오탈자 / 존댓말 / 개발자 용어 / 한·영 리소스)

### 5-1. 한/영 리소스 정합성 — ✅ PASS

```
ko keys: 282   en keys: 282
ko에만 있는 키: 없음 / en에만 있는 키: 없음
en 값이 한국어 그대로인 키: 없음
```

### 5-2. 개발자 용어·원시 예외 노출 — ❌ 10곳

`l.commonError(e.toString())` = **"오류: {error}"** 에 예외 객체를 그대로 넣는다 (8곳):
`community_letter_write_screen.dart:88`, `community_screen.dart:116`, `create_group_screen.dart:50`,
`group_detail_screen.dart:663,1007`, `group_info_screen.dart:196`, `join_group_screen.dart:41`, `notice_write_screen.dart:43`

추가로 `recent_records_section.dart:27` `l.recordLoadError(e)`도 예외 객체 직접 삽입.

**가장 나쁜 실증 경로:** `community_provider.dart:220`
```dart
throw Exception('그룹 인원이 꽉 찼습니다 (${group.maxMembers}명)');
```
→ `join_group_screen.dart:41`에서 영어 UI 사용자에게 이렇게 뜬다:
> **`Error: Exception: 그룹 인원이 꽉 찼습니다 (10명)`**

한 문장에 ①개발자 용어(`Exception:`) ②미번역 한국어 ③원시 예외 문자열이 전부 들어간다.
오프라인이면 `SocketException: Failed host lookup: 'ljtsytknzfcuahqtbmqe.supabase.co'`처럼 **Supabase 프로젝트 URL까지 노출**된다. → **PS-UI-05**

### 5-3. 존댓말 톤 — ✅ 일관

전수 확인 결과 해요체로 통일돼 있고 오탈자 없음. 다만 어미가 "-되었습니다"(`writeSaved`)와 "-했어요"(`errGoogleFailed`)로 섞여 있으나
문장 격식 차이 수준이라 결함으로 보지 않음(정보성).

### 5-4. 에러 문구가 원인+해결책을 말하는가

`errPrayerNotFound`("이미 삭제된 기록이에요. 새로고침 후 다시 시도해주세요."), `searchError` 등은 ✅ 원인+행동 제시.
반면 `commonError`는 원인도 해결책도 없이 예외 원문만 던진다.

### 5-5. 하드코딩 버전 문자열 — ❌ 3곳

| 위치 | 값 |
|---|---|
| `settings_screen.dart:98` | `'PrayStory · v1.0.0'` (화면 표시) |
| `feedback_screen.dart:66` | `'app_version': '1.0.0+1'` (**DB 저장**) |
| `feedback_screen.dart:92` | `'1.0.0+1'` (메일 본문) |

현재는 `pubspec.yaml:5` `version: 1.0.0+1`과 일치하지만 **다음 작업이 배포용 버전 bump**다.
bump 후 피드백 테이블에 잘못된 버전이 기록되면 사용자 제보를 버전별로 분류할 수 없다 → **PS-UI-11**

---

## 6. 다크모드

§0 계산 결과 기준. **다크에서 `accent`를 전경으로 쓰는 모든 지점이 미달**이며, 대표 사례:

| 지점 | 근거 | 다크 대비 | 사용자 영향 |
|---|---|---|---|
| 텍스트 버튼 저장/나가기/내보내기/변경/삭제 | `group_detail_screen.dart:420,447,994`, `group_info_screen.dart:55,78,98,241` | 1.84 | 버튼 글자가 카드에 묻힘 |
| 루트 로딩 스피너 | `main.dart:114` | 2.48 | 앱 시작 로딩이 거의 안 보임 |
| 입력 포커스 테두리 | `login_screen.dart:240`, `signup_step1_screen.dart:169`, `profile_form.dart:283`, `feedback_screen.dart:169`, `join_group_screen.dart:114`, `group_detail_screen.dart:405` | 2.48 | **어느 칸에 포커스가 있는지 안 보임**(WCAG 2.4.7) |
| 선택 체크 아이콘 | `settings_kit.dart:347`, `profile_form.dart:536`, `signup_step3_screen.dart:327` | 1.84 | 테마·언어 **현재 선택값 식별 불가** |
| 달력 "오늘" 링 | `prayer_calendar.dart:379` | 1.84 | 오늘 표시가 사라짐 |
| 검색결과 날짜 | `history_search_overlay.dart:190` | 1.84 | |
| 작성화면 저장 버튼 | `prayer_write_screen.dart:358` | 2.48 | **비활성(textHint 6.05)이 활성(accent 2.48)보다 잘 보이는 역전** |
| 저장성공 스낵바 본문 | `prayer_write_screen.dart:245` + `main.dart:61` | 2.48 | 배경만 accent로 덮고 글자색은 테마값(`#000000`) 그대로 |

→ **PS-UI-02**

**테마 미대응 위젯:** `notification_settings_screen.dart:24-34`가 시간 선택 다이얼로그에 `ColorScheme.light(...)`를 **강제**한다.
`surface`/`onSurface`만 앱 색으로 덮고 나머지 슬롯(다이얼 배경, 선택 하이라이트 등)은 라이트 기본값이 남아
다크 모드에서 어두운 면에 어두운 요소가 겹칠 것으로 보인다. **실기기 확인 필요** → **PS-UI-14**

**하드코딩 색 점검:** `Color(0x...)` 리터럴 16곳 중
- ✅ 정당: 카카오/구글 브랜드색(`login_screen.dart:162-171`), 공지카드 크림 그라데이션(`group_detail_screen.dart:548-555` — `isDark` 분기 있음), 테마 미리보기 카드(`signup_step3_screen.dart:243-245` — 두 테마를 동시에 보여줘야 하므로 고정이 맞음)
- ❌ 문제: 아바타 그라데이션(`group_detail_screen.dart:934,1039-1040`)과 미래날짜(`prayer_calendar.dart:355`)는 분기 없음 → **PS-UI-13**

**FAB:** `AppColors.fabColor`가 `#000000` 고정(`app_colors.dart:27`)인데 다크 bottomBar가 `#121212`라 **대비 1.12:1** —
버튼의 원형 자체가 배경에 녹아 흰 `+` 아이콘만 떠 보인다(아이콘 대비 21:1이라 기능은 함) → **PS-UI-13**

---

## 7. 접근성

| 항목 | 결과 |
|---|---|
| `Semantics(` 사용 | **0건** (앱 전체) |
| `tooltip:` 사용 | **0건** (앱 전체) |
| 폰트 배율 | ✅ PS-UI-01 수정분 — `main.dart:94-102` `clamp(maxScaleFactor: 1.0)` |
| TalkBack 포커스 순서 | **미확인** (정적 분석 불가 — §11) |

- 아이콘 전용 버튼 라벨 부재는 **기등록 PS-A11Y-01**(백로그 유지 중). 이번 심사에서 재확인만 하고 재등록하지 않음.
- **하단 탭:** `_NavItem`이 `label`을 받아놓고 `build()`에서 **렌더하지도, Semantics에 넘기지도 않는다**(`main.dart:283-313`).
  즉 라벨 문자열(`'기도 기록'`, `'커뮤니티'`, `'설정'` — `:239,262,269`)은 **하드코딩 한국어인 채로 죽어 있다.**
  텍스트 라벨 제거는 의도된 디자인이므로 시각적 복구가 아니라 **Semantics 연결**이 맞는 처리다.
- **달력 날짜 셀:** 스크린리더가 "15"만 읽고 "기록 있음/오늘"을 전달하지 못한다(`prayer_calendar.dart:358-400`).

### 터치 타깃 (≥48dp)

| 대상 | 실제 | 판정 |
|---|---|---|
| 하단 탭 FAB | 48×48 | ✅ `main.dart:248-249` |
| 공지·편지 삭제 X | 48×48 | ✅ PS-ACT-02 수정분 |
| 달력 화살표 | 48×48 | ✅ PS-ACT-03 수정분 |
| **멤버 내보내기** | **≈27×19dp** | ❌ `group_detail_screen.dart:1059-1063` — `GestureDetector`+`Icon(size:19)`+`Padding(left:8)`. **PS-ACT-02와 동일 결함인데 이 지점만 누락됨** |
| **달력 날짜 셀** | 화면폭 의존 | ⚠️ 좌우 여백 합 56dp ÷ 7열 → **360dp 화면에서 43.4dp(미달)**, 392dp 이상에서 48dp 충족 |

→ **PS-UI-12**

---

## 8. 신앙 앱 특성

| 항목 | 판정 | 근거 |
|---|---|---|
| 기도문 실수 삭제 방지 | ✅ **양호** | 확인 다이얼로그 + Undo 스낵바(B1) + `created_at` 보존 복원 |
| 삭제 발견성 | ◑ 롱프레스만 | 기등록 PS-FLOW-06(S4) |
| **계정 삭제 실수 방지** | ❌ | 탈퇴 타일이 로그아웃과 동일 외형(§2-2) → **PS-UI-04** |
| 기도문 로컬 잔존 | ✅ | 로그아웃·탈퇴 시 `LocalPrayerStore.clearAll()`(`account_screen.dart:24,50`) — FR-007 충족 |
| 공유·백업 경로 노출 | ✅ 해당 없음 | 기도문 공유/내보내기 기능 자체가 없음. 커뮤니티 편지는 별도 테이블이고 익명 표시(`anonymousName`/`anonymousEmoji`) |
| 스크린샷 차단 | 미적용 | 개인 기록 앱이나 본인 기기 열람이 전제 — 결함 아님(정보성) |
| **문구 톤(압박 여부)** | ✅ **양호** | 통계 카드가 "이번 달 기록 / 응답"만 노출(`stats_summary_row.dart:33-43`). **`streakCount`(연속 기록)는 계산만 하고 어디에도 표시하지 않는다** — 압박 요소 없음. 다만 미사용 코드로 남음(**PS-UI-17**) |
| 익명 처리 | ✅ | 편지 작성 시 익명 닉네임+이모지 자동 부여(`community_provider.dart:234`) |

---

## 9. 첫 사용자 경험 (데이터 0건)

| 탭 | 0건 상태 화면 | 판정 |
|---|---|---|
| 서신서 | 날짜 헤더 + `homeEmptyToday` 안내문 + 페이지 전체 탭→작성 | ✅ 양호 |
| 기도 기록 | 통계 `0일`/`0회` + 빈 달력 + **지난기록 섹션 통째로 사라짐**(`recent_records_section.dart:31`) + 검색창 | ◑ 달력 아래가 비어 허전함 |
| 커뮤니티 | `_EmptyGroups` + "모임 만들기" CTA | ✅ **가장 좋은 구현** |
| 설정 | 정상 | ✅ |

기록 탭이 "이 화면에서 뭘 해야 하는지" 안내 없이 0으로만 차 있다 → **PS-UI-09**에 포함.

---

## 10. SPEC-GAP (결함 아님 — 성헌 판정 필요)

> `docs/CLAUDE.md` 원칙 5: 명세에 없는 동작은 결함이 아니라 SPEC-GAP으로 분류하고 판정을 묻는다.

| ID | 내용 | 근거 | 물어볼 것 |
|---|---|---|---|
| **SG-01** | ✅ **판정 완료(2026-07-28): 손대지 않음.** 기록탭 달력 경유로 충분하다고 판단, 현재 동작 유지. SPEC-GAP 아님(SPEC 4장 SCR-05와 모순 없음, 의도된 축소로 확정). | `home_screen.dart` 전체에 `PageView`/`onHorizontalDrag`/피커 없음. git `c9ff357`에서 `PageView` 제거 | (해소됨) |
| **SG-02** | ✅ **판정 완료·구현 완료(2026-07-28)** — 출시 전 필수로 판정, 6자리 코드 방식으로 구현. `password_reset_screen.dart` 신규, `login_screen.dart`에 진입 링크 추가. FR-016(`docs/SPEC.md`) 신규 등록. **남은 것: 실기기 검증 + 출시 전 커스텀 SMTP 등록**(Supabase 기본 발송기는 시간당 2통·팀 멤버 한정이라 실사용자에겐 메일 미발송). | `lib/screens/auth/password_reset_screen.dart`, `login_screen.dart:9,151-169` | (해소됨) |
| **SG-03** | ✅ **판정 완료(2026-07-28): 확인 다이얼로그 없음으로 확정, 코드 수정 안 함.** 알람은 재생성이 쉬워 즉시삭제가 의도된 동작으로 확정. SPEC-GAP 아님. | `notification_settings_screen.dart:125-127` | (해소됨) |

---

## 11. 실기기 확인이 필요한 항목 (2단계로 이월)

정적 분석으로 **판정을 확정할 수 없어** 미확인으로 남긴 것 + 수치는 확정됐으나 체감 확인이 필요한 것.

| # | 확인 항목 | 이유 | 관련 |
|---|---|---|---|
| D-1 | **다크모드 전 화면 스크린샷** (홈/기록/커뮤니티/그룹상세/설정/작성/로그인) | §0 계산은 확정이나 실제 육안 심각도와 우선순위 결정에 필요 | PS-UI-02 |
| D-2 | 시간 선택 다이얼로그를 **다크모드에서** 열어보기 | `ColorScheme.light` 강제의 실제 파손 정도가 코드만으론 불확정 | PS-UI-14 |
| D-3 | **TalkBack 켜고** 하단탭·달력·아이콘 버튼 포커스 순서/읽는 내용 | 정적 분석 불가 | PS-A11Y-01, PS-UI-12 |
| D-4 | 갤럭시 S23 **화면폭(dp) 실측** 후 달력 셀 크기 확인 | 360dp면 43.4dp로 미달, 392dp 이상이면 충족 | PS-UI-12 |
| D-5 | 알림 권한 **거부 상태**에서 알람 토글 ON → 실제 알림 오는지 | 권한 거부 시 UI가 ON으로 남는지 실증 | PS-UI-08 |
| D-6 | 오프라인에서 **로그인 버튼** 탭 | 무응답 여부 실증(코드상 catch 누락 확정) | PS-UI-10 |
| D-7 | 검색어 0건 매칭 시 패널 거동 | 아무것도 안 뜨는지 실증 | PS-UI-09 |
| D-8 | 홈 화면 **느린 네트워크**에서 진입 | Loading 미구현 체감 시간 확인 | PS-UI-03 |
| D-9 | FAB·기도문 항목 탭 시 눌림 표현 유무 | 리플 부재 체감 | PS-UI-12 |

---

## 12. 판정 요약

| 항목 | 판정 | 신규 결함 |
|---|---|---|
| 1. 4상태 | ❌ FAIL | PS-UI-03, 06, 09 |
| 2. 일관성 | ❌ FAIL | PS-UI-04, 16 |
| 3. 피드백 | ❌ FAIL | PS-UI-12, 15 |
| 4. 내비게이션 | ◑ 부분 | PS-UI-18 (+ SG-01, SG-02) |
| 5. 문구 | ❌ FAIL | PS-UI-05, 11 (한/영 리소스는 ✅ PASS) |
| 6. 다크모드 | ❌ **FAIL (최중요)** | PS-UI-02, 13, 14 |
| 7. 접근성 | ❌ FAIL | PS-UI-12 (+ 기등록 PS-A11Y-01) |
| 8. 신앙 앱 특성 | ◑ 부분 | PS-UI-04 (기도문 보호는 ✅ 양호) |
| 9. 첫 사용자 경험 | ◑ 부분 | PS-UI-09 |

**신규 결함 17건 — S1 0건 / S2 0건 / S3 10건 / S4 7건.**
S1·S2가 없어 **출시 차단 요소는 아니나**, S3 10건 중 다크모드(PS-UI-02)는 영향 범위가 앱 전역이고
근본 원인이 `app_colors.dart:21` 한 줄이라 **수정 대비 효과가 가장 크다.**

### 권장 처리 순서

1. **PS-UI-02** — `accent`에 다크 분기 추가 (1줄, 영향 103곳)
2. **PS-UI-04** — 탈퇴 타일 `destructive: true` + `settings_kit`의 destructive를 `danger`로 + `Colors.red`→`danger` 통일
3. **PS-UI-03 / PS-UI-09** — 조용한 빈 화면 4곳에 상태 표시
4. **PS-UI-05 / PS-UI-10** — 예외 원문 노출 제거 + `catch (_)` 보강 (PS-FLOW-01과 동일 처방)
5. **PS-UI-11** — 버전 문자열 단일화 (**배포 버전 bump 전에 처리해야 의미 있음**)
6. 나머지 S4는 배포 후 백로그 후보

---

## 13. 수정 결과 (2026-07-27, 성헌 승인 후 일괄 수정)

**신규 결함 17건(PS-UI-02 ~ PS-UI-18) 전부 수정 완료.** `flutter analyze` **error/warning 0 · info 21**
(수정 전 23 → 죽은 코드 제거로 `withOpacity` info 2건 감소. 신규 이슈 0)

### 팔레트 재설계 — 수정 후 대비비

`accent`가 **전경·배경 겸용**이라 한쪽을 고치면 다른 쪽이 깨지는 구조였다.
**채움용 `accent` / 전경용 `accentText`** 두 토큰으로 분리하고 전경 사용처 76곳을 치환했다.

| 조합 | 라이트 | 다크 | 판정 |
|---|---|---|---|
| textHint on background | 5.19 | 6.98 | ✅ (이전 3.32 / 6.05) |
| textHint on card | 4.73 | 5.16 | ✅ (이전 3.02 / 4.47) |
| **accentText on background** | 8.45 | **9.63** | ✅ (이전 다크 2.48) |
| **accentText on card** | 7.71 | **7.12** | ✅ (이전 다크 1.84) |
| danger on card | 4.96 | **5.20** | ✅ (이전 다크 2.85) |
| 흰 글씨 on accent(채움) | 8.45 | 5.49 | ✅ |
| accent(채움) vs 배경 | 8.45 | 3.83 | ✅ UI 3:1 충족 |
| 아바타 이니셜 흰 글씨 | 5.25 / 5.74 | 동일 | ✅ (이전 1.63 / 3.60) |

`textHint`(라이트 `#9C8A7A`→`#7A6A5C`, 다크 `#8F897F`→`#9A948A`)와 `danger`(다크 `#E57373` 분기)도 함께 조정.
아바타 그라데이션은 `#D9C9A8`→`#7A6A4E`, `#B07A6A`→`#8F5849`로 어둡게 해 흰 이니셜이 읽히게 했다.

### 신규 파일

| 파일 | 목적 |
|---|---|
| `lib/widgets/error_retry_view.dart` | 공용 에러 표시 + **재시도 버튼**(PS-UI-06). 예외 원문 대신 ARB 문구만 노출 |
| `lib/core/constants/app_info.dart` | 버전 문자열 단일 출처(PS-UI-11). **릴리스 시 `pubspec.yaml`과 함께 갱신 필요** |

### 주요 동작 변경

| 결함 | 변경 |
|---|---|
| PS-UI-03 | 홈 `loading`=스피너, `error`=`ErrorRetryView`. 서버 오류 시 빈 화면 → 안내+재시도 |
| PS-UI-04 | 탈퇴 타일 `destructive: true`, `settings_kit`의 destructive를 `accent`→`danger`, `Colors.red`→`danger` |
| PS-UI-05 | `GroupFullException` 신설. `commonError(e.toString())` **10곳 전부 제거**, 원문은 `debugPrint`로만 |
| PS-UI-07 | 테마 시트의 `system` 제외 필터 제거 + `MediaQuery.platformBrightnessOf`로 기기 테마 실시간 반영 |
| PS-UI-08 | `_ensurePermission()` — 알림 권한 거부 시 **알람을 켜지 않고** 안내 스낵바 |
| PS-UI-09 | 검색 0건 문구 / 지난기록 빈 상태 카드 / 통계 실패 시 `0` 대신 `—` |
| PS-UI-10 | 로그인 3경로·프로필저장·**탈퇴**·피드백에 `catch (_)` 보강 (PS-FLOW-01과 동일 처방) |
| PS-UI-12 | 내보내기 `IconButton` 48dp, 달력 셀 43.4→**45.1dp**(360dp 기준), FAB `InkWell`+`Semantics`, 탭 라벨 l10n화 |
| PS-UI-16 | 한국어만 `저장하기`/`삭제하기`/`수정하기`로 어미 통일 (영어는 기존 표현 유지) |
| PS-UI-17 | `AppThemeModeLabel`·`SettingsProfileHeader` 제거. `_NavItem.label`은 삭제 대신 `Semantics`로 연결 |

신규 ARB 키 9개 추가(ko/en 동수) → `flutter gen-l10n` 재생성. **ko 291 / en 291 키 일치.**

### ⚠️ 남은 한계 (정직하게 기록)

- **달력 셀 45.1dp** — 360dp 화면에서 48dp를 완전히 채우려면 좌우 여백을 12dp 미만으로 낮춰야 해 레이아웃이 무너진다. 43.4→45.1로 개선했으나 **48dp 미달은 유지**된다.
- **`textHint` on bottomBar 4.18:1** — 미선택 탭 아이콘에만 쓰이는 조합이라 UI 컴포넌트 기준 3:1은 충족하나 텍스트 기준 4.5:1에는 미달.
- **PS-A11Y-01**(아이콘 버튼 tooltip 전무)은 2026-07-28에 **부분 수정**: 뒤로가기 14곳에 `tooltip` 추가(전체 28곳의 절반). 나머지 14곳(삭제·비밀번호표시·달력이동 등)은 백로그 유지. 하단 탭·FAB에는 이전에 `Semantics` 추가돼 있었음(중복 아님, 별도 위젯).
- **SPEC-GAP 3건(SG-01 홈 날짜 이동 / SG-02 비밀번호 재설정 / SG-03 알람 삭제 확인)은 손대지 않았다.** 명세 판정이 필요한 사안이라 성헌 결정 대기.

### 실기기 재검증 필요 (§11 목록에 아래 항목 추가)

| # | 항목 | 이유 |
|---|---|---|
| D-10 | **라이트 모드 전 화면 스크린샷** | `textHint`를 앱 전역에서 어둡게 바꿔 인상이 달라짐 — 회귀 확인 필수 |
| D-11 | **다크 모드 전 화면 스크린샷** | `accentText` 76곳 치환 결과 확인 |
| D-12 | 기록탭 달력 레이아웃 + **폰트배율 200%** 재확인 | 달력 좌우 여백을 14→8로 줄여 PS-UI-01 검증 조건이 바뀜 |
| D-13 | 회원탈퇴 타일이 빨갛게 보이는지 | `destructive: true` 적용 시각 확인 |
| D-14 | 설정→테마에 "시스템 설정"이 보이고 선택되는지 | PS-UI-07 |

---

## 14. 실기기 검증 결과 (2026-07-27, 갤럭시 S23 / SM-S911N)

수정본 debug APK 설치 후 검증. **자동(adb) 7건 + 사용자 육안 5건 전부 PASS.**

### 14-1. 화면 폭 실측 — §7 수치 정정

| 항목 | 값 |
|---|---|
| 물리 해상도 | 1080 × 2340 |
| 밀도 | physical 480 / **override 420** |
| **논리 폭** | **1080 ÷ (420/160) = 411.4dp** |

→ **§7의 "360dp 화면에서 43.4dp 미달"은 이 기기의 기본 설정에서는 발생하지 않는다.**
수정 전에도 (411−56)/7 = **50.7dp로 48dp 충족**이었고, 수정 후는 (411−44)/7 = **52.4dp**.
360dp 조건은 **디스플레이 줌을 최대로 올렸을 때만** 재현된다(밀도 480 → 1080/3 = 360dp).
PS-UI-12의 달력 셀 항목은 **"특정 디스플레이 확대 설정에서만 발생"**으로 범위를 좁혀 읽어야 한다.

### 14-2. 자동 검증 (스크린샷 확보)

| 결함 | 검증 내용 | 결과 |
|---|---|---|
| PS-UI-02 | 다크 테마 시트의 선택 체크(✓) 식별 | ✅ 또렷하게 보임 |
| PS-UI-02 | 다크 달력 "오늘"(27일) 원 테두리 | ✅ 선명 (수정 전 1.84:1) |
| PS-UI-04 | 설정→계정: 탈퇴 타일이 빨강, 로그아웃은 회색 | ✅ 확실히 구분됨 |
| PS-UI-07 | 테마 시트에 "시스템 설정" 노출 | ✅ 표시됨 |
| PS-UI-07 | 시스템 선택 후 기기 테마 변경 시 **앱 재시작 없이** 즉시 반영 | ✅ 동작 |
| PS-UI-09 | 기록 탭 "아직 기록이 없어요" 빈 상태 카드 | ✅ 표시됨 |
| PS-UI-13 | 다크 하단 FAB 원형 테두리 | ✅ 배경과 구분됨 |
| PS-UI-01 회귀 | 달력 여백 14→8 축소 후 1~31일 표시 | ✅ 정상 |

### 14-3. 사용자 육안 확인 (성헌, 전부 정상 확인)

| # | 항목 | 결과 |
|---|---|---|
| 1 | 검색 빈 결과 "검색 결과가 없어요" | ✅ |
| 2 | 오프라인 로그인 시 네트워크 안내(PS-UI-10) | ✅ |
| 3 | 알림 권한 거부 시 알람 안 켜지고 안내(PS-UI-08) | ✅ |
| 4 | 라이트 모드 전체 톤(textHint 상향 회귀) | ✅ 문제 없음 |
| 5 | 폰트배율 최대에서 달력 1~31일 | ✅ |

### 14-4. 실기기에서 새로 발견 — **PS-UI-19 (S2)**

**회원탈퇴 안내 문구가 실제 동작과 반대다.** 화면은 "비활성화 처리"라고 하는데
`supabase/functions/delete-account/index.ts`는 `admin.deleteUser`로 **즉시 완전 삭제**한다(SPEC Q6 확정과도 일치).
정적 리뷰에서 ARB 문구와 Edge Function 동작을 대조하지 않아 놓친 항목 —
**문구 심사 시 "코드 동작"뿐 아니라 "배포된 서버 함수 동작"까지 대조해야 한다는 교훈.**
상세는 `qa/04_defects.md` PS-UI-19. **미수정(문구 확정 대기).**

### 14-5. PS-UI-19 수정 완료 (2026-07-27)

성헌 확정 문구로 ko/en 4개 문자열 교체. **실제 동작(`admin.deleteUser` + CASCADE)·SPEC Q6와 일치.**

| 키 | 수정 후 (ko) |
|---|---|
| `accountWithdrawNote` | 탈퇴하면 계정과 작성하신 모든 기도 기록이 즉시 영구 삭제되며 복구할 수 없어요. |
| `accountWithdrawConfirm` | 탈퇴하면 계정과 모든 기도 기록이 즉시 삭제되고 복구할 수 없어요.\n정말 탈퇴하시겠어요? |

⚠️ **후속 필요:** 개인정보처리방침 문서와 Play Console 데이터 세이프티 신고 내용도
"즉시 완전 삭제"로 3자 일치시켜야 한다(SPEC 9장). 아직 미작성 상태이므로 배포 트랙에서 처리할 것.

---

## 15. 6단계 종료 판정

| 항목 | 결과 |
|---|---|
| 심사 범위 | 9개 항목 전수, `lib/` 도달 가능 화면 전체 |
| 발견 결함 | **18건** (정적 17 + 실기기 1) — S2 1 / S3 10 / S4 7 |
| 수정 | **18건 전부 완료** |
| 정적 검증 | `flutter analyze` error/warning **0**, info 21 (수정 전 23) |
| 실기기 검증 | 자동 8건 + 육안 5건 **전부 PASS** (갤럭시 S23) |
| 잔여 S1·S2 | **0건** |
| 잔여 S3 | 0건 |
| 잔여 S4 | 0건 (PS-A11Y-01은 6단계 이전부터 백로그 승인된 항목) |

**→ QA 6단계(UI/UX 심사) 종료.**

### 이월 항목 (6단계 스코프 밖)

| 구분 | 내용 |
|---|---|
| 백로그 | **PS-A11Y-01** — 아이콘 버튼 tooltip. 단 하단 탭·FAB에는 Semantics 추가돼 일부 개선됨 |
| SPEC-GAP | **SG-01** 홈 날짜 이동 수단 / **SG-02** 비밀번호 재설정 경로 부재 / **SG-03** 알람 삭제 확인 — 셋 다 성헌 판정 대기 |
| 배포 트랙 | 개인정보처리방침·데이터 세이프티에 "즉시 완전 삭제" 반영(PS-UI-19 후속), `AppInfo` 버전 bump |
| 알려진 한계 | 달력 셀 45.1dp(디스플레이 확대 최대 시), textHint on bottomBar 4.18:1 |
