#!/bin/bash
# Notification hook: 許可プロンプト・アイドル等でClaudeが入力待ちになったら通知を送る
#
# Stop hookは応答完了時にしか発火しないため、許可待ちでブロックしている間は
# 通知が出ない。このhookがその隙間を埋める。
# 外部プッシュ(ntfy)は ~/bin/notify の "input" ラベル定型文のみ (自由文は出ない)。
set -euo pipefail

INPUT=$(cat)

TITLE_FILE="/tmp/claude-session-title"

title=""
if [ -f "$TITLE_FILE" ]; then
  title=$(head -1 "$TITLE_FILE" | sed 's/^[[:space:]]*//' | head -c 30)
fi

if [ -n "$title" ]; then
  message="${title} 入力待ち"
else
  message="Claude Code 入力待ち"
fi

~/bin/notify "$message" "input"

exit 0
