# auto-epub-to-pdf

`~/Downloads` 폴더에 EPUB 파일이 추가되면 자동으로 PDF로 변환하는 macOS 도구입니다.

## 요구사항

- macOS
- [Calibre](https://calibre-ebook.com/download) (`ebook-convert` 명령어)

## 설치

```bash
./install.sh
```

설치 시 다음이 수행됩니다:
- `ebook-convert` 존재 여부 확인
- 변환 스크립트를 `~/.local/bin/`에 설치
- LaunchAgent를 `~/Library/LaunchAgents/`에 등록

## 제거

```bash
./uninstall.sh
```

## 동작 방식

1. macOS LaunchAgent가 `~/Downloads` 폴더를 감시
2. 폴더에 변경이 감지되면 변환 스크립트 실행
3. 같은 이름의 PDF가 없는 EPUB만 변환
4. 변환 시작/완료/실패 시 macOS 알림 표시

## 알림

| 시점 | 알림 |
|------|------|
| 변환 시작 | ⏳ 파일명.epub |
| 변환 완료 | ✓ 파일명.pdf |
| 변환 실패 | ✗ 파일명.epub |

## 로그

```bash
cat ~/.local/log/epub-to-pdf.log
```

## 파일 구조

```
├── convert-epub.sh              # 변환 스크립트
├── com.user.epub-to-pdf.plist   # LaunchAgent 설정
├── install.sh                   # 설치
└── uninstall.sh                 # 제거
```
