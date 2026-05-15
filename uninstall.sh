#!/bin/bash

PLIST_DEST="$HOME/Library/LaunchAgents/com.user.epub-to-pdf.plist"
SCRIPT_PATH="$HOME/.local/bin/convert-epub.sh"

echo "=== EPUB → PDF 자동 변환 제거 ==="

# 1. LaunchAgent 비활성화
if [ -f "$PLIST_DEST" ]; then
    launchctl bootout "gui/$(id -u)/com.user.epub-to-pdf" 2>/dev/null || true
    rm "$PLIST_DEST"
    echo "✓ LaunchAgent 제거 완료"
else
    echo "- LaunchAgent가 이미 제거되어 있습니다"
fi

# 2. 스크립트 제거
if [ -f "$SCRIPT_PATH" ]; then
    rm "$SCRIPT_PATH"
    echo "✓ 변환 스크립트 제거 완료"
else
    echo "- 변환 스크립트가 이미 제거되어 있습니다"
fi

echo ""
echo "=== 제거 완료 ==="
echo "로그 파일은 ~/.local/log/epub-to-pdf*.log에 남아있습니다."
echo "로그도 삭제하려면: rm ~/.local/log/epub-to-pdf*.log"
