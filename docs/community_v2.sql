-- 커뮤니티 v2: 그룹 상세 재디자인 (공지 / 서신 / 멤버 + 중보 반응)
-- Supabase SQL Editor에서 한 번 실행하세요. (재실행해도 안전)

-- 1) 모임 설명 + 아이콘(이모지) 컬럼 추가
ALTER TABLE community_groups
  ADD COLUMN IF NOT EXISTS description text NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS icon text NOT NULL DEFAULT '📖';

-- 2) 모임 공지 테이블
CREATE TABLE IF NOT EXISTS group_notices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES community_groups(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE group_notices ENABLE ROW LEVEL SECURITY;

-- 같은 그룹 멤버가 공지 조회
DROP POLICY IF EXISTS "group_notices_select" ON group_notices;
CREATE POLICY "group_notices_select" ON group_notices
  FOR SELECT USING (
    group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
  );

-- 방장만 공지 등록
DROP POLICY IF EXISTS "group_notices_insert" ON group_notices;
CREATE POLICY "group_notices_insert" ON group_notices
  FOR INSERT WITH CHECK (
    auth.uid() = author_id
    AND group_id IN (SELECT id FROM community_groups WHERE owner_id = auth.uid())
  );

-- 방장만 공지 삭제
DROP POLICY IF EXISTS "group_notices_delete" ON group_notices;
CREATE POLICY "group_notices_delete" ON group_notices
  FOR DELETE USING (
    group_id IN (SELECT id FROM community_groups WHERE owner_id = auth.uid())
  );

-- 3) 서신 중보 반응 테이블 (누가 어떤 서신에 "함께 기도" 했는지)
CREATE TABLE IF NOT EXISTS letter_prayers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  letter_id uuid NOT NULL REFERENCES community_letters(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(letter_id, user_id)
);

ALTER TABLE letter_prayers ENABLE ROW LEVEL SECURITY;

-- 누구나 조회 (서신을 볼 수 있는 사람은 중보 현황도 봄)
DROP POLICY IF EXISTS "letter_prayers_select" ON letter_prayers;
CREATE POLICY "letter_prayers_select" ON letter_prayers
  FOR SELECT USING (true);

-- 본인이 중보 추가
DROP POLICY IF EXISTS "letter_prayers_insert" ON letter_prayers;
CREATE POLICY "letter_prayers_insert" ON letter_prayers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 본인이 중보 취소
DROP POLICY IF EXISTS "letter_prayers_delete" ON letter_prayers;
CREATE POLICY "letter_prayers_delete" ON letter_prayers
  FOR DELETE USING (auth.uid() = user_id);

-- 4) 같은 모임 멤버끼리 서로의 이름(프로필)을 볼 수 있게 허용
--    (멤버 목록/공지 작성자/중보 참여자 이름 표시에 필요)
DROP POLICY IF EXISTS "profiles_select_group_members" ON profiles;
CREATE POLICY "profiles_select_group_members" ON profiles
  FOR SELECT USING (
    id = auth.uid()
    OR id IN (
      SELECT user_id FROM group_members
      WHERE group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
    )
  );
