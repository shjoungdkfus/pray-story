# 커뮤니티 기능 명세서

## 1. 개요

"나의 서신서" 앱에 커뮤니티 기능을 추가하여, 사용자들이 기도 편지를 나누고 그룹을 만들어 함께 기도할 수 있도록 한다.

### 하단 탭바 구성 변경
```
| 서신서(0) | 기도기록(1) | +(FAB) | 커뮤니티(2) | 설정(3) |
```

---

## 2. 화면 구조

### 2.1 커뮤니티 홈 (CommunityScreen)
- **상단 타이틀**: "커뮤니티"
- **카테고리 가로 스크롤 영역**:
  - 원형 아이콘 버튼들 (가로 스크롤)
  - 기본 항목: `커뮤니티(전체)`, `누군가를 위해`, `그룹 만들기(+)`
  - 사용자가 만든/참여한 그룹들이 뒤에 추가됨
  - 선택된 항목에 accent 원형 테두리 표시
- **피드 영역**:
  - 커뮤니티 선택 시: 전체 공개 기도 편지 피드 (익명, 날짜, 내용 미리보기)
  - 그룹 선택 시: 해당 그룹의 편지 피드 + 상단 액션 버튼(편지 쓰기, 초대하기, 그룹 정보)

### 2.2 누군가를 위해 기도 (PrayForSomeoneScreen)
- **Step 1**: "누구를 위해 기도하고싶나요?" + 이름 입력 + 다음 버튼
- **Step 2**: 기도 편지 작성 화면 (기존 PrayerWriteScreen 재활용)
  - 상단에 "OO 위한 편지" 표시
  - 공개 범위 선택 드롭다운: 나만보기, 그룹들, 커뮤니티

### 2.3 그룹 만들기 (CreateGroupScreen)
- **비공개 그룹 만들기** 설명 텍스트
- 그룹 이름 입력 필드
- "만들기" 버튼
- "그룹 코드로 조인하러가기" 링크 → JoinGroupScreen

### 2.4 그룹 코드 참여 (JoinGroupScreen)
- 초대 코드 입력 필드
- "참여하기" 버튼

### 2.5 그룹 상세 (그룹 선택 시 커뮤니티 홈 내)
- **액션 버튼 3개**: 편지 쓰기, 초대하기, 그룹 정보
- 그룹 내 편지 피드
- 비어있을 때: 그룹명 + "친구와 가족을 초대하고 함께 기도 편지를 나눠보세요" + 초대하기 버튼

### 2.6 초대하기 (InviteGroupScreen)
- 그룹 아이콘 + 그룹명
- 초대 코드 표시 (복사 버튼)
- "초대 링크 공유하기" 버튼 (시스템 공유 시트)

### 2.7 그룹 정보 (GroupInfoScreen)
- 그룹 아이콘 + 그룹명 (편집 가능, 방장만)
- 멤버 수 표시
- 멤버 리스트 (역할: 방장/멤버)
- 생성일
- 우상단 더보기 메뉴 (그룹 나가기, 방장: 그룹 삭제)

### 2.8 편지 공개 범위 설정
기도 편지 작성 시 공개 범위 선택:
- **나만보기** (기본값, 기존 동작)
- **특정 그룹** (가입한 그룹 목록)
- **커뮤니티** (전체 공개, 익명)

---

## 3. 데이터 모델 (Supabase)

### 3.1 community_groups 테이블
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | 그룹 ID |
| name | text | 그룹 이름 |
| invite_code | text (unique) | 초대 코드 (8자리) |
| owner_id | uuid (FK → auth.users) | 방장 |
| max_members | int | 최대 멤버 수 (기본 5) |
| created_at | timestamptz | 생성일 |

### 3.2 group_members 테이블
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | |
| group_id | uuid (FK) | 그룹 |
| user_id | uuid (FK) | 사용자 |
| role | text | 'owner' / 'member' |
| joined_at | timestamptz | 가입일 |

### 3.3 community_letters 테이블
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | |
| author_id | uuid (FK) | 작성자 |
| group_id | uuid (FK, nullable) | 그룹 (null이면 커뮤니티 전체) |
| recipient_name | text (nullable) | "누군가를 위해" 대상 이름 |
| content | text | 편지 내용 |
| visibility | text | 'private' / 'group' / 'community' |
| anonymous_name | text | 익명 닉네임 (자동 생성) |
| anonymous_emoji | text | 익명 이모지 (자동) |
| created_at | timestamptz | 작성일 |

---

## 4. UI 디자인 가이드

- 기존 앱의 따뜻한 베이지/크림 톤 유지 (AppColors)
- GowunBatang 폰트 사용
- 카드: AppColors.card 배경 + 둥근 모서리 (12px)
- 원형 카테고리 버튼: 60px, accent 테두리로 선택 표시
- 피드 카드: 내용 미리보기 + 날짜 + 익명 닉네임 + 이모지

---

## 5. 구현 순서

1. ~~하단 탭바 5개 구성~~ (커뮤니티 탭 추가)
2. CommunityScreen 기본 레이아웃
3. Supabase 테이블 생성 SQL
4. 모델 + Provider 구현
5. 그룹 만들기/참여 기능
6. 편지 작성 + 공개 범위
7. 커뮤니티 피드
8. 그룹 상세 (초대, 정보)
