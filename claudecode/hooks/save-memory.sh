#!/bin/bash
# Claude Code Stop hook: バックグラウンドで auto-memory を更新する
#
# 旧版は {"decision":"block"} を返してメインセッションの Claude に保存させていたが、
# それだと (1) セッション終了が一手間遅延する、(2) メイン会話のトークンを消費する、
# という問題があった。現版は Stop を block せず即 exit 0 し、別プロセスの headless
# `claude -p` を nohup でバックグラウンド起動して、そちらに save-memory skill を
# 実行させる。本セッションは即座に終了でき、保存は裏で進む。
#
# 仕組み:
#   - hook 入力の transcript_path / cwd / session_id を使ってバックグラウンド起動
#   - 環境変数 CLAUDE_SKIP_SAVE_MEMORY=1 を子プロセスに渡し、子プロセス側の Stop
#     hook が再帰的に save-memory を起動しないようにする (無限増殖防止)
#   - ログとフラグは /tmp/claude-save-memory/ に集約

set -euo pipefail

# 子プロセス (background claude) からの再帰呼び出しを即時カット
if [ "${CLAUDE_SKIP_SAVE_MEMORY:-0}" = "1" ]; then
  exit 0
fi

INPUT=$(cat)

# stop_hook_active が true なら hook 由来の継続中なので何もしない
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# 1 セッション 1 回のみバックグラウンドジョブを起動
FLAG_DIR="/tmp/claude-save-memory"
mkdir -p "$FLAG_DIR"
FLAG_FILE="${FLAG_DIR}/${SESSION_ID}"
if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
  CWD=$(pwd)
fi

# 短すぎるセッションはスキップ (transcript 行数で判定)
LINE_COUNT=$(wc -l < "$TRANSCRIPT_PATH" | tr -d ' ')
THRESHOLD=${CLAUDE_SAVE_MEMORY_THRESHOLD:-20}
if [ "$LINE_COUNT" -lt "$THRESHOLD" ]; then
  exit 0
fi

# フラグを立てる (次回 Stop では skip)
touch "$FLAG_FILE"

LOG_FILE="${FLAG_DIR}/${SESSION_ID}.log"
PROMPT_FILE="${FLAG_DIR}/${SESSION_ID}.prompt"

# プロンプトは quote escape 事故を避けるためファイル経由で受け渡す
cat > "$PROMPT_FILE" <<EOF
あなたは別プロセスのバックグラウンド agent です。直前のメインセッションの transcript
を解析し、save-memory skill の手順に従って auto-memory を更新してください。

- 対象 transcript: ${TRANSCRIPT_PATH}
- プロジェクト cwd: ${CWD}
- skill 定義: ~/.claude/skills/save-memory/SKILL.md (まず読み込むこと)

要件:
1. SKILL.md の Step 1-5 に従う
2. 既存の MEMORY.md と該当トピックファイルを必ず確認し、重複を避ける
3. 新しい知見がなければ何も書かずに「新しい知見はありませんでした」とだけ報告
4. 出力は簡潔な完了報告のみ
EOF

# nohup + disown でバックグラウンド起動。stdin は /dev/null、stdout/stderr はログへ。
# CLAUDE_SKIP_SAVE_MEMORY=1 で子プロセスの Stop hook 再発火を防ぐ。
nohup env CLAUDE_SKIP_SAVE_MEMORY=1 bash -c "
  cd '$CWD'
  PROMPT=\$(cat '$PROMPT_FILE')
  exec claude -p --permission-mode acceptEdits \"\$PROMPT\"
" > "$LOG_FILE" 2>&1 < /dev/null &
disown

exit 0
