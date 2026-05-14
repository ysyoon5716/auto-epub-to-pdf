# 구현 요약: EPUB → PDF 자동 변환

## 생성된 파일

| 파일 | 역할 |
|------|------|
| `convert-epub.sh` | 메인 변환 스크립트. ~/Downloads에서 새 epub을 찾아 PDF로 변환하고 macOS 알림을 표시 |
| `com.user.epub-to-pdf.plist` | macOS LaunchAgent 설정. ~/Downloads 폴더 변경 감지 시 변환 스크립트를 자동 실행 |
| `install.sh` | 설치 스크립트. 의존성 확인 → 파일 복사 → LaunchAgent 등록/활성화 |
| `uninstall.sh` | 제거 스크립트. LaunchAgent 해제 → 관련 파일 삭제 |

## 사용법

### 설치
```bash
./install.sh
```

### 제거
```bash
./uninstall.sh
```

## 동작 방식
1. macOS LaunchAgent가 `~/Downloads` 폴더를 감시
2. 폴더에 변경이 생기면 `convert-epub.sh` 실행
3. 같은 이름의 PDF가 없는 epub 파일만 `ebook-convert`로 변환
4. 변환 결과를 macOS 알림센터로 표시
5. 로그는 `~/.local/log/epub-to-pdf.log`에 기록

## 설치 경로
- 스크립트: `~/.local/bin/convert-epub.sh`
- LaunchAgent: `~/Library/LaunchAgents/com.user.epub-to-pdf.plist`
- 로그: `~/.local/log/epub-to-pdf.log`
