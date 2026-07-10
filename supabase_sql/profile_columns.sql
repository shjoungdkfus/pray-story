-- ============================================================
-- profiles 테이블 — 회원가입 프로필 리디자인용 컬럼 추가
-- (이름·프로필 사진·교회·성별·연령대 입력 폼 지원)
--
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run.
-- 이미 존재해도 안전하도록 IF NOT EXISTS 사용.
-- ============================================================

-- 교회 이름 (선택 입력, 미입력 시 NULL = "소속없음")
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS church text;

-- 출생연도 (연령대 "30대" 계산용. 전체 생년월일 대신 연도만 저장)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS birth_year integer;

-- 참고: gender 컬럼은 기존 그대로 사용하되 값은 '남자' / '여자' 로 저장됩니다.
--       (과거 '남' / '여' 값도 앱에서 자동으로 '남자' / '여자' 로 표시됩니다.)
