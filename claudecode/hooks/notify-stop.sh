#!/bin/bash
# Stop hook: Claudeが応答を終えるたびにデスクトップ通知を送る
#
# 通知内容の優先順:
#   1. セッションタイトルあり → 「タイトル 完了」
#   2. transcriptから自動抽出 → 抽出テキスト
#   3. "Claude Code 完了" (最終フォールバック)
#
# save-memory hookがblockする場合は、Claude がまだ作業中のため通知をスキップし、
# save-memory完了後の再Stopで通知する。
set -euo pipefail

INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
TITLE_FILE="/tmp/claude-session-title"
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# transcriptから最後のアシスタントテキストメッセージを抽出し、要約として使う
extract_summary_from_transcript() {
  if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    return 1
  fi
  # 逆順に走査し、最初に見つかったassistantのtextを返す
  # tac (GNU coreutils) がなければ tail -r (macOS built-in) を使う
  local tac_cmd="tac"
  if ! command -v tac &>/dev/null; then
    tac_cmd="tail -r"
  fi
  $tac_cmd "$TRANSCRIPT_PATH" \
    | jq -r 'select(.type == "assistant")
              | .message.content[]?
              | select(.type == "text")
              | .text' 2>/dev/null \
    | head -1 \
    | sed 's/^[[:space:]]*//' \
    | head -c 80
}

# セッションタイトルを読む
read_session_title() {
  if [ -f "$TITLE_FILE" ]; then
    head -1 "$TITLE_FILE" | sed 's/^[[:space:]]*//' | head -c 30
  fi
}

# 通知を送る
send_notify() {
  local title=""
  local message=""

  title=$(read_session_title)

  if [ -n "$title" ]; then
    message="${title} 完了"
  else
    # タイトルなし → transcriptから抽出を試みる
    local summary=""
    summary=$(extract_summary_from_transcript) || true
    message="${summary:-Claude Code 完了}"
  fi

  # 日本語表示幅を考慮して40文字で切り詰め
  if [ "${#message}" -gt 40 ]; then
    message="${message:0:37}..."
  fi

  ~/bin/notify "$message"
}

# hookによる継続中 (save-memory完了後) → 最終Stopなので通知
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  send_notify
  exit 0
fi

# save-memoryがblockするかを判定 (同じ条件で重複通知を防止)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

will_save_memory=false
if [ -n "$SESSION_ID" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  flag_file="/tmp/claude-save-memory/${SESSION_ID}"
  if [ ! -f "$flag_file" ]; then
    line_count=$(wc -l < "$TRANSCRIPT_PATH" | tr -d ' ')
    threshold=${CLAUDE_SAVE_MEMORY_THRESHOLD:-20}
    if [ "$line_count" -ge "$threshold" ]; then
      will_save_memory=true
    fi
  fi
fi

# save-memoryがblockしない場合 → これが最終Stopなので通知
if [ "$will_save_memory" = "false" ]; then
  send_notify
fi

exit 0
