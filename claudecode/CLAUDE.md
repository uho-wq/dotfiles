## Notification

### セッションタイトル

会話の最初のやり取りで、ユーザーの依頼内容から短いセッションタイトル（15文字以内）を付けてください:
```
echo "nvim telescope設定" > /tmp/claude-session-title
```
- 最初のツール呼び出しと同時に実行してOK
- 内容を端的に表す日本語タイトル（例: "CI修正", "zsh高速化", "PR review #42"）
- 会話中にタイトルを更新する必要はない

### セッションラベル（外部プッシュ通知用）

タイトルと同時に、作業種別ラベルも書いてください:
```
echo "impl" > /tmp/claude-session-label
```
- 許可値: `impl`(実装) / `research`(調査) / `review`(レビュー) / `ci`(CI) / `config`(設定変更) / `docs`(ドキュメント)
- iPhone/Apple Watch へのプッシュ通知（ntfy.sh）にはこのラベル由来の定型文だけが送られる。タイトルや transcript の自由文は外部に出ない
- 不正値・未設定は「Claude Code 完了」にフォールバックするので、迷ったら書かなくてよい

### Stop通知

Stop hookがデスクトップ通知を自動送信します。通知内容の優先順:
1. セッションタイトルあり → 「タイトル 完了」
2. タイトルなし → transcriptから最後のアシスタントテキストを自動抽出
3. いずれもなし → 「Claude Code 完了」

セッションタイトルを設定していれば、通知は自動で適切になります。`/tmp/claude-notify-summary` への要約書き込みは不要です。

Think in English, interact with the user in Japanese.

## 文章の書き方（readable-prose を常時適用）

下記の作文指針はこの CLAUDE.md 経由で常に読み込まれている。まとまった文章（報告・分析・変更説明・PR説明・Slack文面・コミットメッセージ）を書く前に `readable-prose` skill を Skill ツールで別途呼ぶ必要はない。呼んでも同じ内容が二重に載るだけ。

@~/.claude/skills/readable-prose/SKILL.md

hook でも2層で強制している。`UserPromptSubmit` (`hooks/readable-prose-remind.sh`) が毎ターン要点を再注入し、`Stop` (`hooks/readable-prose-lint.sh`) が最終応答を §4 の語で機械検査して、120字以上の本文に残っていれば1回だけ差し戻す。差し戻し理由に語が列挙されるので、その箇所を直して同じ内容を再送する。
