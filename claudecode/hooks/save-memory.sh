#!/bin/bash
# Claude Code Stop hook: セッション終了前にauto-memoryへ知見を保存させる
#
# Stop hookはClaudeが応答を終えるたびに発火する。
# このスクリプトは以下の条件を満たす場合のみClaudeの停止をブロックし、
# 知見の保存を指示する:
#   1. stop_hook_active が false (hookによる継続中でない)
#   2. このセッションでまだ保存していない (フラグファイルで管理)
#   3. セッションが十分な長さ (transcript行数で判定)

set -euo pipefail

INPUT=$(cat)

# stop_hook_activeがtrueなら、既にhookによる継続中 → 許可
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# セッションIDを取得
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# フラグファイルで1セッション1回のみ実行を保証
FLAG_DIR="/tmp/claude-save-memory"
mkdir -p "$FLAG_DIR"
FLAG_FILE="${FLAG_DIR}/${SESSION_ID}"

if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

# transcriptの行数でセッションの長さを判定
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

LINE_COUNT=$(wc -l < "$TRANSCRIPT_PATH" | tr -d ' ')

# 20行未満の短いセッションではスキップ (閾値は調整可能)
THRESHOLD=${CLAUDE_SAVE_MEMORY_THRESHOLD:-20}
if [ "$LINE_COUNT" -lt "$THRESHOLD" ]; then
  exit 0
fi

# フラグを立てる (次回のStopではブロックしない)
touch "$FLAG_FILE"

# Claudeの停止をブロックし、知見の保存を指示
cat << 'EOF'
{
  "decision": "block",
  "reason": "セッション終了前にauto-memoryを更新してください。save-memory skillの手順に従い:\n1. このセッションの会話を振り返り、新しい知見・パターン・決定事項を特定\n2. MEMORY.mdのトピック一覧を読み、該当トピックファイルも確認して重複を避ける\n3. 新しい知見があればトピックの切り方を検討し、トピックファイルに保存してMEMORY.mdのインデックスを同期（なければ書かずに終了）\n4. 保存した内容を簡潔に報告"
}
EOF
