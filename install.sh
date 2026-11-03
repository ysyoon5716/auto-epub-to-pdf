#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_BIN="$HOME/.local/bin"
INSTALL_LOG="$HOME/.local/log"
PLIST_NAME="com.user.epub-to-pdf.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"

# Calibre .app 설치 시 ebook-convert는 앱 번들 내부에만 존재
export PATH="/Applications/calibre.app/Contents/MacOS:$HOME/Applications/calibre.app/Contents/MacOS:$PATH"

echo "=== EPUB → PDF 자동 변환 설치 ==="

# 1. 의존성 확인
check_dependencies() {
    if ! command -v ebook-convert &> /dev/null; then
        echo "오류: ebook-convert를 찾을 수 없습니다."
        echo "Calibre를 설치해주세요: https://calibre-ebook.com/download"
        exit 1
    fi
    echo "✓ ebook-convert 확인 완료"
}

# 2. 디렉토리 생성
setup_directories() {
    mkdir -p "$INSTALL_BIN"
    mkdir -p "$INSTALL_LOG"
    echo "✓ 디렉토리 생성 완료"
}

# 3. 스크립트 설치
install_script() {
    cp "$SCRIPT_DIR/convert-epub.sh" "$INSTALL_BIN/convert-epub.sh"
    chmod +x "$INSTALL_BIN/convert-epub.sh"
    echo "✓ 변환 스크립트 설치 완료: $INSTALL_BIN/convert-epub.sh"
}

# 4. LaunchAgent plist 설치
install_plist() {
    # 기존 에이전트가 있으면 먼저 해제
    if [ -f "$PLIST_DEST" ]; then
        launchctl bootout "gui/$(id -u)/com.user.epub-to-pdf" 2>/dev/null || true
    fi

    # __HOME__ 플레이스홀더를 실제 홈 경로로 치환
    sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/$PLIST_NAME" > "$PLIST_DEST"
    echo "✓ LaunchAgent 설치 완료: $PLIST_DEST"
}

# 5. LaunchAgent 활성화
load_agent() {
    launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
    echo "✓ LaunchAgent 활성화 완료"
}

check_dependencies
setup_directories
install_script
install_plist
load_agent

echo ""
echo "=== 설치 완료 ==="
echo "~/Downloads 폴더에 epub 파일을 넣으면 자동으로 PDF로 변환됩니다."
echo "로그: $INSTALL_LOG/epub-to-pdf.log"
