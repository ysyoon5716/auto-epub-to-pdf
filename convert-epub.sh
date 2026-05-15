#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WATCH_DIR="$HOME/Downloads"
LOG_FILE="$HOME/.local/log/epub-to-pdf.log"

log_result() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

send_notification() {
    local title="$1"
    local message="$2"
    osascript -e "display notification \"$message\" with title \"$title\""
}

convert_to_pdf() {
    local epub_file="$1"
    local basename="${epub_file%.epub}"
    local pdf_file="${basename}.pdf"

    # 파일 크기가 안정될 때까지 대기 (다운로드 완료 확인)
    local prev_size=-1
    local curr_size
    curr_size=$(stat -f%z "$epub_file" 2>/dev/null || echo 0)
    while [ "$curr_size" != "$prev_size" ]; do
        prev_size=$curr_size
        sleep 2
        curr_size=$(stat -f%z "$epub_file" 2>/dev/null || echo 0)
    done

    if ebook-convert "$epub_file" "$pdf_file" >> "$LOG_FILE" 2>&1; then
        log_result "성공: $epub_file → $pdf_file"
        send_notification "EPUB → PDF 변환 완료" "✓ $(basename "$pdf_file")"
    else
        log_result "실패: $epub_file"
        send_notification "EPUB → PDF 변환 실패" "✗ $(basename "$epub_file")"
    fi
}

find_new_epubs() {
    for epub_file in "$WATCH_DIR"/*.epub; do
        [ -f "$epub_file" ] || continue

        local basename="${epub_file%.epub}"
        local pdf_file="${basename}.pdf"

        if [ -f "$pdf_file" ]; then
            continue
        fi

        echo "$epub_file"
    done
}

# 메인 실행
mkdir -p "$(dirname "$LOG_FILE")"

# 다운로드 완료를 기다리기 위해 잠시 대기
# (WatchPaths는 임시 파일 생성 시점에 트리거될 수 있음)
sleep 5

new_epubs=$(find_new_epubs)

if [ -z "$new_epubs" ]; then
    exit 0
fi

while IFS= read -r epub_file; do
    log_result "변환 시작: $epub_file"
    send_notification "EPUB → PDF 변환 시작" "⏳ $(basename "$epub_file")"
    convert_to_pdf "$epub_file"
done <<< "$new_epubs"
