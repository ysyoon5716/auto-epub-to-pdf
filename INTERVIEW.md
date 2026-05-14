# 인터뷰 결과

## 요구사항 요약
`~/Downloads` 폴더에 epub 파일이 생기면 자동으로 같은 이름의 PDF로 변환한다.

## 결정 사항

### 1. 파일 감시 방식: macOS LaunchAgent
- macOS 네이티브 방식으로 폴더를 감시
- 로그인 시 자동 시작, 별도 프로세스 관리 불필요
- 리소스 소모가 거의 없음

### 2. PDF 저장 위치: 같은 Downloads 폴더
- 원본 epub과 동일한 `~/Downloads` 폴더에 PDF를 생성

### 3. 원본 epub 처리: 그대로 유지
- 변환 완료 후 원본 epub 파일을 삭제하거나 이동하지 않음

### 4. 변환 알림: macOS 알림센터 사용
- 변환 성공/실패 시 macOS 알림(notification)을 표시

### 5. ebook-convert 경로: PATH에 등록됨
- `ebook-convert` 명령어가 PATH에 등록되어 있으므로 전체 경로 없이 사용 가능

## 기술 스택
- **변환 도구**: `ebook-convert` (Calibre, PATH에 등록됨)
- **감시 방식**: macOS LaunchAgent (WatchPaths 사용)
- **알림**: `osascript`를 통한 macOS 알림센터
- **구현 언어**: Shell script (bash/zsh)
