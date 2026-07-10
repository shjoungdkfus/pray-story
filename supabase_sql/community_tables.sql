-- 커뮤니티 그룹 테이블
CREATE TABLE IF NOT EXISTS community_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  invite_code text NOT NULL UNIQUE,
  owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  max_members int NOT NULL DEFAULT 5,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE community_groups ENABLE ROW LEVEL SECURITY;

-- 누구나 읽기 (초대 코드 조회용)
CREATE POLICY "community_groups_select" ON community_groups
  FOR SELECT USING (true);

-- 로그인한 사용자가 생성
CREATE POLICY "community_groups_insert" ON community_groups
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- 방장만 수정
CREATE POLICY "community_groups_update" ON community_groups
  FOR UPDATE USING (auth.uid() = owner_id);

-- 방장만 삭제
CREATE POLICY "community_groups_delete" ON community_groups
  FOR DELETE USING (auth.uid() = owner_id);


-- 그룹 멤버 테이블
CREATE TABLE IF NOT EXISTS group_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES community_groups(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member',
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(group_id, user_id)
);

ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- 같은 그룹 멤버끼리 조회
CREATE POLICY "group_members_select" ON group_members
  FOR SELECT USING (true);

-- 로그인한 사용자가 참가
CREATE POLICY "group_members_insert" ON group_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 본인 탈퇴
CREATE POLICY "group_members_delete" ON group_members
  FOR DELETE USING (auth.uid() = user_id);


-- 커뮤니티 편지 테이블
CREATE TABLE IF NOT EXISTS community_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  group_id uuid REFERENCES community_groups(id) ON DELETE CASCADE,
  recipient_name text,
  content text NOT NULL,
  visibility text NOT NULL DEFAULT 'community',
  anonymous_name text NOT NULL DEFAULT 'anonymous',
  anonymous_emoji text NOT NULL DEFAULT '🌻',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE community_letters ENABLE ROW LEVEL SECURITY;

-- 커뮤니티 전체 공개 편지는 누구나 조회
CREATE POLICY "community_letters_select_public" ON community_letters
  FOR SELECT USING (visibility = 'community');

-- 본인 편지 조회
CREATE POLICY "community_letters_select_own" ON community_letters
  FOR SELECT USING (auth.uid() = author_id);

-- 같은 그룹 멤버가 그룹 편지 조회
CREATE POLICY "community_letters_select_group" ON community_letters
  FOR SELECT USING (
    visibility = 'group'
    AND group_id IN (
      SELECT group_id FROM group_members WHERE user_id = auth.uid()
    )
  );

-- 로그인한 사용자가 작성
CREATE POLICY "community_letters_insert" ON community_letters
  FOR INSERT WITH CHECK (auth.uid() = author_id);

-- 본인 편지 삭제
CREATE POLICY "community_letters_delete" ON community_letters
  FOR DELETE USING (auth.uid() = author_id);
