#!/bin/bash
# UserPromptSubmit hook: 毎ターン、readable-prose の要点をコンテキスト末尾に注入する
#
# CLAUDE.md の @import で SKILL.md 全文はシステムプロンプトに載っているが、
# 長い会話では先頭の指示は効きが落ちる。生成直前の位置に短い要約を置いて
# 「説明テキストを書くなら readable-prose を適用する」を毎ターン思い出させる。
#
# 本文の検査は readable-prose-lint.sh (Stop hook) が担う。ここは注意喚起だけ。
set -euo pipefail

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"[readable-prose] 説明テキスト(報告・分析・変更説明・PR/Slack文面)を書くときは readable-prose を適用する: (1)1行目が答え (2)一文一義・40〜60字 (3)「〜を行う」「〜できます」等の名詞化を動詞に (4)§4の定型句(承知しました/適切に/〜が挙げられます 等)を書かない (5)断定と推測を書き分ける。Stop hook が §4 の語を機械検査し、残っていれば差し戻す。一言で済む返答には枠を被せない。"}}
JSON
