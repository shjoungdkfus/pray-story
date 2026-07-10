-- ============================================================
-- 설정 탭 개편용 Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 실행하세요.
-- ============================================================

-- 1) 피드백 테이블 -------------------------------------------------
create table if not exists public.feedback (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users (id) on delete set null,
  email       text,
  category    text not null,                 -- '버그 신고' | '기능 제안' | '문의' | '기타'
  message     text not null,
  app_version text,
  created_at  timestamptz not null default now()
);

alter table public.feedback enable row level security;

-- 로그인한 사용자는 본인 명의로 피드백을 남길 수 있다.
drop policy if exists "feedback_insert_own" on public.feedback;
create policy "feedback_insert_own"
  on public.feedback
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- 본인이 보낸 피드백만 조회 가능 (관리자는 service_role 또는 대시보드에서 확인).
drop policy if exists "feedback_select_own" on public.feedback;
create policy "feedback_select_own"
  on public.feedback
  for select
  to authenticated
  using (auth.uid() = user_id);


-- 2) 회원 탈퇴(소프트 삭제)용 컬럼 ---------------------------------
-- profiles 테이블에 비활성화 시각을 기록한다.
alter table public.profiles
  add column if not exists deleted_at timestamptz;

-- 참고: 클라이언트(anon key)에서는 auth.users 를 직접 삭제할 수 없으므로
--      현재는 profiles.deleted_at 표시 + 로그아웃으로 처리한다.
--      추후 service_role 을 쓰는 Edge Function 으로 실제 계정 삭제를
--      구현하면, 아래처럼 로그인 시 deleted_at 을 확인해 차단할 수 있다.
--
--      select deleted_at from public.profiles where id = auth.uid();
