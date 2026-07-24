-- ============================================================
-- QA 7단계(2026-07-25) 보안검증에서 발견한 2건 수정
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 실행하세요. (재실행 안전, DROP IF EXISTS 사용)
-- 근거: qa/07_rls_security_audit.md, qa/04_defects.md
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- [수정 1 · PS-SEC-01, S2] 같은 그룹 멤버끼리 profiles 조회가 안 되던 문제
--   증상: B가 A와 같은 그룹에 참여해도 GET .../profiles?id=eq.{A} 가 빈 배열 반환.
--   원인: community_v2.sql:70-78 에 이 정책이 정의돼 있었으나 실제 프로젝트엔
--         적용이 안 돼 있었던 것으로 추정(재확인 결과 원인이 다르면 이 재실행은
--         무해하게 기존 정책을 덮어씀).
--   영향: 그룹 멤버 목록/공지 작성자/중보 참여자 이름이 전부 "익명"으로만 보이는
--         원인이었을 가능성 큼(community_provider.dart:_profileNames 헬퍼가 이 select를
--         3곳에서 공유).
-- ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "profiles_select_group_members" ON profiles;
CREATE POLICY "profiles_select_group_members" ON profiles
  FOR SELECT USING (
    id = auth.uid()
    OR id IN (
      SELECT user_id FROM group_members
      WHERE group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
    )
  );


-- ────────────────────────────────────────────────────────────
-- [수정 2 · PS-SEC-02, S3, 실악용경로 없음] letter_prayers가 편지 가시성과 무관하게 동작
--   증상: private/group 가시성 편지라도 letter_id만 알면 누구나 "함께 기도" 반응을
--         추가하거나 반응 목록을 조회할 수 있었음(편지 본문 자체는 안 새어나감).
--   조치: insert/select 둘 다 "해당 편지를 실제로 볼 수 있는 사용자"로 제한 —
--         community_letters의 3개 select 정책과 동일한 조건을 그대로 반영.
-- ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "letter_prayers_select" ON letter_prayers;
CREATE POLICY "letter_prayers_select" ON letter_prayers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM community_letters cl
      WHERE cl.id = letter_prayers.letter_id
        AND (
          cl.visibility = 'community'
          OR cl.author_id = auth.uid()
          OR (
            cl.visibility = 'group'
            AND cl.group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
          )
        )
    )
  );

DROP POLICY IF EXISTS "letter_prayers_insert" ON letter_prayers;
CREATE POLICY "letter_prayers_insert" ON letter_prayers
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM community_letters cl
      WHERE cl.id = letter_prayers.letter_id
        AND (
          cl.visibility = 'community'
          OR cl.author_id = auth.uid()
          OR (
            cl.visibility = 'group'
            AND cl.group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
          )
        )
    )
  );
