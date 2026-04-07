---
name: ci-watch
description: CIの完了を監視し、終わったら通知します。「CI終わったら教えて」「CI監視して」「CIの結果待って」「watch ci」「CI完了通知」などで発動。
---

# CI Watch

現在のPRまたは指定されたPRのCI状態を監視し、完了したらterminal-notifierで通知する。

## ワークフロー

### Step 1: PR情報取得

引数がある場合はそのPR番号を使用。なければ現在のブランチのPRを対象。

```bash
# 現在のブランチのPR情報を取得
gh pr view --json number,title,headRefName
```

### Step 2: CI監視実行

Bashツールの`run_in_background`オプションを使用してバックグラウンドで監視:

```bash
gh pr checks {PR番号} --watch 2>&1
```

### Step 3: 完了通知

CI完了後、結果に応じて通知:

- **成功時**: `terminal-notifier -title "CI Passed ✅" -message "PR #XXX: タイトル" -sound default`
- **失敗時**: `terminal-notifier -title "CI Failed ❌" -message "PR #XXX: タイトル" -sound Basso`

### Step 4: 結果報告

ユーザーに結果を報告し、詳細な出力があれば共有する。

## 使用例

- `/ci-watch` - 現在のブランチのPRを監視
- `/ci-watch 123` - PR #123を監視
- 「CI終わったら教えて」- 自然言語でも発動
