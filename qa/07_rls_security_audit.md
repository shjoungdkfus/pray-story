# QA 7단계 — RLS 크로스계정 보안검증 (07_rls_security_audit.md)

> 사용자 지시로 1단계 완료 직후 이 단계로 건너뜀(정상 순서 0→1→2…→7 중 2~6 생략, 사용자 승인).
> **테스트 전용 Supabase 프로젝트가 없어 운영 프로젝트에 접두사(`praystory.qa.*`) 붙인 임시 계정 3개로 실행 → 종료 후 앱의 `delete-account` Edge Function으로 전부 자가정리**(계정/프로필/기도문/피드백 삭제 + 소유 그룹은 CASCADE로 정리, 사용자에게 사전 확인 후 진행).
> 실행 스크립트: 세션 스크래치패드(`rls_test.mjs`, 재현용 원본은 이 리포트 하단 방법론 참고 — 세션 종료 후 접근 불가하니 필요시 이 문서의 케이스 설계를 그대로 재구현할 것).

## 실행 결과 요약

- **RUN ID:** `mrzba151` (2026-07-25 실행)
- **계정:** A(방장, `praystory.qa.a.mrzba151@example.com`) / B(멤버) / C(외부인) — 3개, 전부 실제 `signup`으로 세션 발급받아 anon key로만 REST 직접 호출(클라이언트가 실제로 처리할 수 있는 권한과 동일 조건, service_role 미사용).
- **결과: 31건 중 명확 판정 29건 — PASS 28 / FAIL 1**, 정보성(판정 보류, 아래 해설) 2건.
- **테스트 계정 자가정리 완료** — A/B/C 전부 `delete-account` Edge Function 호출 성공(`status=200, {"success":true}`), 운영 DB에 남은 테스트 데이터 없음.

| 판정 | 건수 |
|---|---|
| PASS | 28 |
| **FAIL(확인된 결함)** | **1** |
| 정보성(별도 해설 필요) | 2 |

---

## ❌ 확인된 결함

### PS-SEC-01

| 항목 | 내용 |
|---|---|
| 심각도 | **S2 Critical** |
| 관련 요구사항 | SPEC-GAP(SPEC.md에 "그룹 멤버끼리 서로 이름 표시" 항목이 FR로 명문화돼 있지 않음 — 코드 구현 의도는 명확) |
| 위치 | Supabase 대시보드 RLS 정책(`profiles` 테이블) — 파일 근거는 `supabase_sql/community_v2.sql:70-78`(`profiles_select_group_members` 정책 정의) |
| 현상 | 같은 그룹에 속한 두 사용자가 서로의 `profiles` 행을 select로 조회하지 못한다. |
| 재현 절차 | 1. 계정 A가 그룹 생성 2. 계정 B가 해당 그룹에 정상 참여(`group_members` insert 성공, PS-SEC-14 PASS 확인) 3. B의 JWT로 `GET /rest/v1/profiles?id=eq.{A의 uid}` 호출 4. 빈 배열(`[]`) 반환 |
| 기대 결과 | `supabase_sql/community_v2.sql:70-78`의 `profiles_select_group_members` 정책대로 `id = auth.uid() OR id IN (같은 그룹 멤버 목록)`이면 조회 허용돼야 함 |
| 실제 결과 | 조회 결과 0행 — 정책이 적용되지 않은 것과 동일한 동작 |
| 근본 원인 | 파일(`community_v2.sql`)에는 이 정책이 존재하지만, **실제 Supabase 프로젝트에 이 정책 블록이 적용되지 않았거나 이후 다른 마이그레이션으로 덮어써진 것으로 추정.** (같은 파일의 `group_notices`/`letter_prayers` 테이블·정책은 실제로 동작 확인됨 — PS-SEC-20~27에서 해당 테이블 CRUD가 정상 작동하므로 파일 자체를 통째로 안 돌린 것은 아니고, 이 특정 정책 블록만 누락됐을 가능성이 큼) — **SQL 편집기 대시보드 조회로 `pg_policies`에서 `profiles` 테이블 정책 목록을 직접 확인해야 확정 가능(현재 세션엔 Management API 토큰 없어 REST 결과로만 판단, 판단 근거는 확실함).** |
| 실서비스 영향 | `community_provider.dart:37-48`(`_profileNames` 헬���)가 그룹 멤버 목록(`groupMembersProvider`), 공지 작성자 이름(`groupNoticesProvider`), 중보 참여자 이름(`letterPrayerProvider`) **세 곳 전부에서** 이 profiles 조회를 재사용함. 코드가 `member.userName ?? l.anonymous`(`group_detail_screen.dart:992`) 같은 null-폴백을 갖고 있어 **크래시는 없지만, 실제 사용자들은 지금 커뮤니티 어디서도 서로의 실명을 못 보고 전부 "익명"/"멤버"로만 보일 가능성이 높다.** 이는 커뮤니티 탭의 핵심 가치(누가 함께 기도하는지 아는 것)를 무력화하는 수준. |
| 수정 제안 | Supabase 대시보드 SQL Editor에서 `supabase_sql/community_v2.sql`의 68~78행(`profiles_select_group_members` `DROP POLICY IF EXISTS`+`CREATE POLICY`) 블록만 다시 실행 → 재검증(같은 REST 호출로 확인). |
| 회귀 위험 | 없음(정책 추가는 조회 범위를 넓히는 방향이라 기존 동작 깨뜨리지 않음) — 단, 재실행 전 실제 원인이 "정책 미적용"이 맞는지 `pg_policies` 조회로 먼저 확인 권장(다른 정책과 충돌 가능성 배제). |
| 검출 기법 | 상태 전이/권한 매트릭스 기반 오류 추정 — "그룹 참여 전/후" 상태 변화에 따른 접근권한 전이 테스트 |

---

## ℹ️ 정보성 발견 — 판정 보류, 사용자 확인 필요

### PS-SEC-02 (letter_prayers 크로스 가시성)

| 항목 | 내용 |
|---|---|
| 잠정 심각도 | S3 Major (실제 공격 경로는 제한적 — 아래 설명) |
| 위치 | `supabase_sql/community_v2.sql:54-66`(`letter_prayers_select`/`_insert` 정책) |
| 현상 | ① B가 자신이 볼 수 없어야 할(private 가시성) A의 편지 id를 직접 지정해 `letter_prayers`에 "함께 기도" 반응을 insert할 수 있음(성공, `status=201`). ② C(그 편지와 무관한 외부인)가 같은 편지 id로 `letter_prayers`를 select하면 반응 기록(누가 반응했는지)이 그대로 조회됨. |
| 재현 절차 | 1. A가 `visibility='private'` 편지 작성 2. B가 (테스트이므로 이미 알고 있는) 그 편지의 `id`로 `POST /rest/v1/letter_prayers {letter_id, user_id:B}` 호출 → 201 3. C가 같은 `letter_id`로 `GET /rest/v1/letter_prayers?letter_id=eq.{id}` 호출 → 200, 1행 반환 |
| 기대 결과(추정) | `letter_prayers`의 insert/select 모두 "해당 letter를 실제로 볼 수 있는 사용자만" 허용해야 논리적으로 일관 — 즉 `community_letters`의 SELECT 정책과 동등한 조건이 `letter_prayers`에도 걸려야 함 |
| 실제 결과 | `letter_prayers_insert`는 `auth.uid()=user_id`만 확인(편지 가시성 무관), `letter_prayers_select`는 `USING(true)`(전체 공개) — 편지 자체의 visibility와 완전히 분리돼 있음 |
| **실제 악용 가능성 평가(중요)** | **낮음.** `letter_id`는 무작위 UUID이고, 이 세션의 1단계 인벤토리(`qa/00_inventory.md`)에서 이미 확인했듯 앱의 어떤 화면·API 응답에서도 private 편지의 id가 작성자 본인 외에는 노출되지 않는다(select 정책 자체는 정상적으로 작성자 전용으로 막혀 있음, PS-SEC-21 PASS). 즉 이 결함이 실제로 악용되려면 공격자가 이미 다른 경로로 그 UUID를 알고 있어야 하는데, 그 경로가 현재 앱에는 없다. |
| 수정 제안(선택) | ① `letter_prayers_insert`의 `WITH CHECK`에 `letter_id IN (해당 사용자가 볼 수 있는 community_letters 조건)` 추가, ② `letter_prayers_select`도 `USING(true)` 대신 같은 조건으로 제한. 다만 위험도가 낮고 커뮤니티 기능은 P2(SPEC QA 범위 확정표 기준)라 **출시를 막을 이유는 아님 — 백로그로 남기는 것을 제안.** |
| 검출 기법 | 오류 추정(간접 참조 무결성 미검증 패턴) |

**★ 사용자 판정 필요:** 이 항목을 지금 고칠지, 출시 후 백로그로 미룰지 정해주시면 됩니다. (제 권장: 미루기 — 실질 노출 경로가 없고 커뮤니티는 P2 영역이라 우선순위상 위 PS-SEC-01이 훨씬 급함)

---

## ✅ PASS 확인된 항목 (구멍 없음, 근거 있음)

| 영역 | 확인 내용 | 케이스 |
|---|---|---|
| `prayers` | 본인만 select/update/delete 가능, 타인·비로그인은 전부 차단. **비로그인이 전체 조회 시도해도 0건**(민감정보인 기도문 테이블의 가장 중요한 방어선 — 정상 확인) | PS-SEC-01~07 |
| `profiles` | 그룹 무관계일 땐 타인 프로필 완전 차단, 비로그인도 차단 | PS-SEC-08~09 |
| `community_groups` | `owner_id` 위조 insert 차단, 비방장 수정 차단, 외부인 삭제 차단 | PS-SEC-10~13 |
| `group_members` | 위조 멤버 추가(동의 없는 초대) 차단, 비방장 강퇴 차단, 방장 강퇴는 정상 허용(2026-07-03 수정 사항 재검증 통과) | PS-SEC-14~19 |
| `community_letters` | private는 그룹 동료여도 차단, group 가시성은 멤버만/비멤버 차단, 본인 아닌 삭제 차단 | PS-SEC-20~24 |
| `feedback` | 타인 조회 차단, 명의 위조 insert 차단, 비로그인 전체조회 차단 | PS-SEC-28~31 |

정원(`max_members`) DB 트리거(`enforce_group_capacity`, `rls_fixes.sql:28-55`)는 이번 세션엔 재실행하지 않음(2026-07-03에 이미 검증 완료 기록 있고, 이번 그룹은 2명만 참여시켜 5명 한도에 안 닿았음) — **재확인이 필요하면 별도로 5명 채우는 테스트를 다시 돌려야 함(이번 회차는 스킵).**

---

## 방법론 (재현용 기록)

- **API 방식**: PostgREST(`/rest/v1/<table>`) + GoTrue(`/auth/v1/signup`) 직접 호출, `fetch()`(Node 24 내장) 사용. `apikey` 헤더는 항상 anon key, `Authorization: Bearer <token>`을 계정별 access_token 또는 anon key 자체(비로그인 시뮬레이션)로 교체.
- **판정 기준**: select는 빈 배열(`[]`)을, write는 `401/403` 또는 PostgREST 코드 `42501`(RLS 위반)을 "차단됨"으로 판정. 일부는 write가 `204`(성공 응답)를 반환해도 실제로 반영 안 됐을 수 있어 **직후 소유자 계정으로 재조회해서 값이 실제로 안 바뀌었는지 이중 확인**(PS-SEC-06, 12, 24 등).
- **정리**: 앱에 이미 구현된 `delete-account` Edge Function(`supabase/functions/delete-account/index.ts`)을 각 테스트 계정 자신의 JWT로 호출 — service_role 키 없이도 자가삭제 가능, 실제 사용자가 겪는 탈퇴 경로와 동일해서 부수적으로 이 Edge Function 자체도 이번에 다시 한번 정상 동작 확인됨(3개 계정 전부 200 성공).
- **재현 시 참고**: 이 문서의 "재현 절차"란을 그대로 스크립트화하면 된다. 테스트 계정 이메일은 `praystory.qa.*@example.com` 패턴 유지 권장(과거 세션 정리 SQL과 호환).
