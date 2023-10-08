# 너도나도 테트리스
항해 플러스 코육대에 참가하면서 앱 개발로 도전해 본 과제입니다.
* web version: [https://hanghae-bae7d.web.app](https://hanghae-bae7d.web.app/)
* ios version: [앱 스토어](https://apps.apple.com/kr/app/%EB%84%88%EB%8F%84%EB%82%98%EB%8F%84-%ED%85%8C%ED%8A%B8%EB%A6%AC%EC%8A%A4/id6468504024)

## get started
- `firebase_options.dart` 세팅 필요
- `flutter pub get` 후 `flutter run`

## updated
- 아래로 스와이프해서 블럭을 최하단으로 내리는 제스처 기능 추가
- 우측 상단에 게임 일시정지 / 다시재생 버튼 추가
- 좌측 상단에 다음 블럭 미리보기 추가
- 게임 진행 중 'I' 블럭 두번째 회전 시 픽셀 사라짐 현상 수정
- 게임 진행 중 우측 상단 픽셀이 깨지면서 게임 멈춤 현상 수정