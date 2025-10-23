# 🃏 Card Album App

카드를 촬영하고 텍스트를 자동으로 인식하여 관리하는 Flutter 애플리케이션입니다.

## ✨ 주요 기능

- 📸 **카드 촬영**: 실시간 카메라로 카드 촬영
- 🤖 **AI 카드 감지**: TensorFlow Lite 모델로 카드 영역 자동 인식
- 📝 **OCR 텍스트 인식**: Google ML Kit을 활용한 텍스트 추출
- 💾 **카드 저장**: 크롭된 카드 이미지와 텍스트 자동 저장
- 🔍 **검색 기능**: 저장된 카드를 텍스트로 검색
- 📚 **앨범 관리**: 저장된 카드를 그리드 뷰로 보기

## 🛠 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Camera Plugin**: 카메라 기능
- **Google ML Kit**: 텍스트 인식 (OCR)
- **TensorFlow Lite**: 카드 영역 감지 모델
- **Image Package**: 이미지 처리 및 크롭

## 📁 프로젝트 구조

```
lib/
  └── main.dart              # 메인 앱 로직
      ├── CardData           # 카드 데이터 모델
      ├── MyCardsPage        # 저장된 카드 목록
      ├── SearchPage         # 카드 검색
      └── CameraScreen       # 카메라 촬영 화면

assets/
  └── card_detector.tflite   # 카드 감지 TFLite 모델
```

## 🚀 시작하기

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 모델 파일 준비
`assets/card_detector.tflite` 파일이 있는지 확인하세요.

### 3. 앱 실행
```bash
flutter run
```

## 📱 화면 구성

1. **카메라 화면** (메인): 카드 촬영 및 실시간 인식
2. **MYCARD**: 저장된 카드를 그리드로 표시
3. **SEARCH**: 텍스트 기반 카드 검색

## 🔧 개발 환경

- Flutter SDK: ^3.7.2
- Dart: ^3.7.2

## 📝 TODO

- [ ] 영구 저장소(SQLite/SharedPreferences) 적용
- [ ] 카드 삭제 기능 추가
- [ ] 카드 상세보기 화면
- [ ] 카테고리/태그 기능
- [ ] 클라우드 동기화 
