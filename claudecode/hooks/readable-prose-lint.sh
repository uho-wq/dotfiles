#!/bin/bash
# Stop hook: 最終応答に readable-prose §4 の定型句が残っていたら1回だけ差し戻す
#
# 検査対象: 直近のユーザー発話以降のアシスタントテキスト(コードブロック・インラインコード除外)
# パターン源: SKILL.md の §4 にある「…」を毎回パースする(readable-prose-add で追加した語も自動で対象になる)
# スキップ条件:
#   - stop_hook_active=true (すでに差し戻し済み。無限ループ防止)
#   - 本文が MIN_CHARS 未満 (一言の確認・雑談は対象外)
#   - パターンに一致しない
# 出力: 一致があれば {"decision":"block","reason":"…"} を返し、Claude に書き直しを求める
set -euo pipefail

SKILL_MD="${READABLE_PROSE_SKILL_MD:-$HOME/.claude/skills/readable-prose/SKILL.md}"
MIN_CHARS="${READABLE_PROSE_MIN_CHARS:-120}"

INPUT=$(cat)

if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

TRANSCRIPT_PATH=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] || [ ! -f "$SKILL_MD" ]; then
  exit 0
fi

# GNU tac がなければ macOS の tail -r
if command -v tac &>/dev/null; then
  reverse() { tac "$@"; }
else
  reverse() { tail -r "$@"; }
fi

# 直近のユーザー発話(tool_result でないもの)より後の行だけを取り出す
LAST_TURN=$(reverse "$TRANSCRIPT_PATH" \
  | awk '/"type":"user"/ && !/"tool_result"/ {exit} {print}' \
  | reverse)

if [ -z "$LAST_TURN" ]; then
  exit 0
fi

# アシスタントのテキストを結合し、コードを除外
TEXT=$(printf '%s\n' "$LAST_TURN" \
  | jq -rs '[ .[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text ]
            | join("\n")
            | gsub("```.*?```"; ""; "m")
            | gsub("`[^`\n]*`"; "")')

TEXT_LEN=$(printf '%s' "$TEXT" | LC_ALL=C.UTF-8 wc -m 2>/dev/null || printf '%s' "$TEXT" | wc -m)
if [ "${TEXT_LEN// /}" -lt "$MIN_CHARS" ]; then
  exit 0
fi

# §4 の「…」を正規表現に変換
#   - 「（→ …」以降(置き換え例)は削る
#   - 「乱用」「無理に」を含む行は字面一致で判定できないので除外
#   - 〜 は 同一文内の 1〜12 文字(句点・改行を含まない)に置き換える
PATTERNS=$(jq -Rrs '
  split("## §4")[1] | split("\n## §")[0]
  | split("\n")
  | map(select(startswith("- ")))
  | map(select((test("乱用") or test("無理に")) | not))
  | map(sub("（→.*$"; ""))
  | map([match("「([^」]+)」"; "g").captures[0].string]) | add
  | map(gsub("〜"; "[^。\\n]{1,12}"))
  | unique | .[]
' "$SKILL_MD")

if [ -z "$PATTERNS" ]; then
  exit 0
fi

HITS=$(printf '%s' "$TEXT" | jq -Rrs --rawfile pats <(printf '%s\n' "$PATTERNS") '
  . as $text
  | ($pats | split("\n") | map(select(length > 0))) as $ps
  | [ $ps[] | . as $p | ($text | match($p; "g")?.string) ]
  | unique | .[0:6]
  | map("「" + . + "」") | join("")
')

if [ -z "$HITS" ]; then
  exit 0
fi

jq -nc --arg hits "$HITS" '{
  decision: "block",
  reason: ("[readable-prose lint] §4 の定型句が残っています: " + $hits
    + "。該当箇所を書き直したうえで、同じ内容の回答を再送してください。"
    + "構造・事実・確認事項は削らないこと。コード内や引用文中の語なら、その旨を1行添えて再送すればよい。")
}'
