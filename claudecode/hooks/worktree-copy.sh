#!/bin/bash
# SessionStart hook: worktree 内で起動した場合に untracked ファイルをコピーする

# Worktree detection: git-common-dir と git-dir が異なれば worktree 内
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
git_dir=$(git rev-parse --git-dir 2>/dev/null) || exit 0

git_common_dir=$(cd "$git_common_dir" && pwd)
git_dir=$(cd "$git_dir" && pwd)

# メインワークツリーなら何もしない
[ "$git_common_dir" = "$git_dir" ] && exit 0

# メインワークツリーのパスを取得
main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')

# コピー対象ファイル（存在する場合のみ、上書きなし）
for file in .gitignore .envrc .mcp.json; do
  [ -f "$main_worktree/$file" ] && [ ! -f "$file" ] && cp "$main_worktree/$file" .
done

# .claude/ ディレクトリ（再帰、上書きなし）
if [ -d "$main_worktree/.claude" ]; then
  cp -Rn "$main_worktree/.claude" . 2>/dev/null || true
fi
