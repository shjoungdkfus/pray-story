# 개발 기록 (CHANGELOG)

매일 개발한 내용을 날짜별로 기록합니다. 최신 날짜가 위로 오도록 추가합니다.

---

## 2026-06-23

### 앱 아이콘 (Launcher Icon) 적용
- 새로 디자인한 로고(버건디 배경 + 크림색 P+S 펜촉)를 앱 런처 아이콘으로 적용
- `flutter_launcher_icons` 패키지를 사용해 Android 전 해상도(mdpi~xxxhdpi) 아이콘 생성
- **적응형 아이콘(Adaptive Icon)** 추가 구성
  - 로고에서 배경을 투명 처리해 전경(foreground) 이미지로 분리
  - 펜촉 끝부분이 원형 마스크 등에서 잘리지 않도록 안전영역(safe zone) 기준 약 82% 크기로 축소·중앙 정렬
  - 배경색(`#60041B`)을 별도 레이어로 분리하여 삼성(둥근 사각형), Pixel(원형) 등 런처별 마스크 모양에 관계없이 일관되게 표시되도록 함

**변경 파일**
- `pubspec.yaml`: `flutter_launcher_icons` 설정에 `adaptive_icon_background`, `adaptive_icon_foreground` 추가
- `assets/icon/app_icon.png` (신규): 원본 1024x1024 아이콘
- `assets/icon/app_icon_foreground.png` (신규): 배경 투명 처리된 전경 이미지
- `android/app/src/main/res/mipmap-*/ic_launcher.png`: 해상도별 기본 아이콘 갱신
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (신규): 적응형 아이콘 정의
- `android/app/src/main/res/drawable-*/ic_launcher_foreground.png` (신규): 해상도별 전경 이미지
- `android/app/src/main/res/values/colors.xml` (신규): 적응형 아이콘 배경색 정의
