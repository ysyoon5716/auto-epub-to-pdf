# 구현 계획: epub → PDF 자동 변환

## 개요
`~/Downloads` 폴더에 epub 파일이 추가되면 macOS LaunchAgent가 이를 감지하고, 셸 스크립트를 실행하여 자동으로 PDF로 변환한다.

## 구성 파일

```
auto-epub-to-pdf/
├── convert-epub.sh          # 변환 스크립트
├── install.sh               # 설치 스크립트
├── uninstall.sh             # 제거 스크립트
└── com.user.epub-to-pdf.plist  # LaunchAgent 설정 파일
```

## 구현 상세

### 1. 변환 스크립트 (`convert-epub.sh`)

**역할**: ~/Downloads 폴더에서 epub 파일을 찾아 PDF로 변환

**흐름**:
1. `find_new_epubs` — ~/Downloads에서 아직 변환되지 않은 epub 파일 목록을 수집
   - 같은 이름의 PDF가 이미 존재하면 건너뜀
2. `convert_to_pdf` — 각 epub에 대해 `ebook-convert`를 실행
   - 입력: `{이름}.epub` → 출력: `{이름}.pdf` (같은 폴더)
3. `send_notification` — 변환 결과를 macOS 알림으로 표시
   - 성공: "✓ {파일명}.pdf 변환 완료"
   - 실패: "✗ {파일명} 변환 실패"
4. `log_result` — 변환 로그를 파일에 기록 (`~/.local/log/epub-to-pdf.log`)

**중복 변환 방지 전략**:
- 동일 이름의 PDF가 이미 존재하면 변환을 건너뜀
- LaunchAgent는 폴더 변경 시마다 스크립트를 실행하므로, epub이 아닌 파일 변경에도 트리거됨 → epub이 없으면 즉시 종료

### 2. LaunchAgent 설정 (`com.user.epub-to-pdf.plist`)

**역할**: ~/Downloads 폴더를 감시하고 변경 시 변환 스크립트 실행

**주요 설정**:
- `WatchPaths`: `~/Downloads` — 이 폴더에 변경이 생기면 스크립트 실행
- `ProgramArguments`: `convert-epub.sh` 경로
- `RunAtLoad`: false — 로그인 시 불필요한 실행 방지
- `StandardOutPath` / `StandardErrorPath`: 로그 경로 지정

### 3. 설치 스크립트 (`install.sh`)

**역할**: LaunchAgent를 시스템에 등록하고 활성화

**흐름**:
1. `check_dependencies` — `ebook-convert` 명령어 존재 여부 확인
2. `setup_directories` — 로그 디렉토리 생성 (`~/.local/log/`)
3. `install_script` — 변환 스크립트를 `~/.local/bin/`에 복사하고 실행 권한 부여
4. `install_plist` — plist 파일을 `~/Library/LaunchAgents/`에 복사 (경로를 사용자 홈으로 치환)
5. `load_agent` — `launchctl load`로 LaunchAgent 활성화
6. 설치 완료 메시지 출력

### 4. 제거 스크립트 (`uninstall.sh`)

**역할**: LaunchAgent를 해제하고 관련 파일 정리

**흐름**:
1. `launchctl unload`로 에이전트 비활성화
2. plist 파일 및 스크립트 파일 제거
3. 제거 완료 메시지 출력

## 설치 후 동작 흐름

```
사용자가 epub 다운로드
        ↓
macOS가 ~/Downloads 변경 감지
        ↓
LaunchAgent가 convert-epub.sh 실행
        ↓
스크립트가 새 epub 파일 탐색
        ↓
ebook-convert로 PDF 변환
        ↓
macOS 알림 표시 ("변환 완료" / "변환 실패")
```
