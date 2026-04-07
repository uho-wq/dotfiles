#!/bin/bash
# Claude Code completion notification with tmux pane jump support

# Exit if not in tmux
if [[ -z "$TMUX" ]]; then
  # Not in tmux, just show notification
  osascript -e 'display notification "処理が完了しました" with title "Claude Code"'
  exit 0
fi

# Get current tmux session, window, and pane info
TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_WINDOW=$(tmux display-message -p '#I')
TMUX_PANE=$(tmux display-message -p '#P')

# Create payload: "session|window|pane"
PAYLOAD="${TMUX_SESSION}|${TMUX_WINDOW}|${TMUX_PANE}"

# Base64 encode the payload
ENCODED=$(echo -n "$PAYLOAD" | base64)

# Send user variable to WezTerm via escape sequence
# This will trigger the user-var-changed event in wezterm.lua
# When in tmux, we need to wrap the escape sequence for passthrough
# Write directly to the terminal device
printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "claude_done" "$ENCODED" > /dev/tty

# Also show macOS notification for visual feedback
osascript -e 'display notification "処理が完了しました。元のpaneに戻ります。" with title "Claude Code"'

exit 0
