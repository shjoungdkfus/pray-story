-- ============================================================
-- 다수 사용자 테스트(2026-07-03)에서 발견한 2건 수정
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 실행하세요. (재실행 안전)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- [수정 1 · 필수] 방장이 멤버를 내보낼 수 있게 (기능이 조용히 안 먹던 버그)
--   증상: 그룹 상세 > "멤버 내보내기" 를 방장이 눌러도 멤버가 안 나가짐.
--   원인: group_members 의 DELETE 정책이 auth.uid()=user_id (본인 탈퇴)만 허용해서
--         방장이 남의 멤버 행을 지우면 0행 삭제(에러 없이 무반응)로 끝났음.
--   조치: 그룹 방장이 자기 그룹의 멤버 행을 삭제할 수 있는 DELETE 정책 추가.
--         (기존 본인탈퇴 정책과 OR 로 함께 적용됨)
-- ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "group_members_delete_by_owner" ON group_members;
CREATE POLICY "group_members_delete_by_owner" ON group_members
  FOR DELETE USING (
    group_id IN (SELECT id FROM community_groups WHERE owner_id = auth.uid())
  );


-- ────────────────────────────────────────────────────────────
-- [수정 2 · 권장] 정원(max_members) 을 DB 에서 강제 (동시참여/우회 방지)
--   증상: 앱은 참여 전에 인원수를 세어 막지만, 그건 클라이언트 체크일 뿐이라
--         두 명이 동시에 참여하거나 API 를 직접 부르면 정원을 넘길 수 있음.
--   조치: group_members INSERT 시점에 그룹 행을 잠그고(FOR UPDATE) 현재 인원을
--         세어 정원 이상이면 막는 BEFORE INSERT 트리거. 동시 참여 경합도 직렬화됨.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION enforce_group_capacity()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cap int;
  cur int;
BEGIN
  -- 그룹 행을 잠가 동시 참여를 직렬화한다.
  SELECT max_members INTO cap FROM community_groups WHERE id = NEW.group_id FOR UPDATE;
  IF cap IS NULL THEN
    RETURN NEW; -- 그룹이 없으면 FK 가 걸러줌
  END IF;
  SELECT count(*) INTO cur FROM group_members WHERE group_id = NEW.group_id;
  IF cur >= cap THEN
    RAISE EXCEPTION '그룹 인원이 꽉 찼습니다 (최대 %명)', cap
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_group_capacity ON group_members;
CREATE TRIGGER trg_enforce_group_capacity
  BEFORE INSERT ON group_members
  FOR EACH ROW EXECUTE FUNCTION enforce_group_capacity();
