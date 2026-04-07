{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-g";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    historyLimit = 100000;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = false;

    extraConfig = ''
      # Split panes
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind \" split-window -v -c "#{pane_current_path}"
      bind C-v split-window -h -c "#{pane_current_path}"
      bind V split-window -f -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Pane navigation (vim-like)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind C-h select-pane -L
      bind C-j select-pane -D
      bind C-k select-pane -U
      bind C-l select-pane -R

      # Window navigation
      bind C-p select-window -p
      bind C-n select-window -n

      # Resize panes
      bind = resize-pane -D 10
      bind + resize-pane -U 50

      # Display
      set -g display-panes-time 2000
      set -g bell-action none
      set -g allow-passthrough on

      # Vi copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi q send -X cancel

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded!"

      # Popup toggle with prefix + f
      bind t if-shell -F '#{==:#{session_name},popup}' {
        detach-client
      } {
        display-popup -d "#{pane_current_path}" -xC -yC -w 80% -h 75% -E 'tmux attach-session -t popup || tmux new-session -s popup'
      }

      # Claude switcher popup (prefix + a)
      bind a display-popup -E -w 80% -h 75% -xC -yC "tmux-claude-switcher"

      # Pane borders (Tokyo Night)
      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#7aa2f7"
      set -g pane-border-status top
      set -g pane-border-format "#[fg=#565f89] #{?pane_title,#{pane_title},#{pane_current_command}} #[default]"

      # Pane naming (prefix + b)
      bind b command-prompt -p "Pane name:" "select-pane -T '%%'"
      set -wg allow-set-title off

      # Transparent background
      set -g window-style "bg=default"
      set -g window-active-style "bg=default"

      # Message style
      set -g mode-style "fg=#7aa2f7,bg=#3b4261"
      set -g message-style "fg=#7aa2f7,bg=#3b4261"
      set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

      # Status bar (Tokyo Night)
      set -g status on
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=default"
      set -g status-interval 1

      # Left: session indicator
      set -g status-left-length 30
      set -g status-left "#[fg=#7aa2f7,bold]  #S #[fg=#3b4261]"

      # Right: empty (minimal)
      set -g status-right ""

      # Window list
      setw -g window-status-separator ""
      setw -g window-status-format "#[fg=#565f89]  #I #W "
      setw -g window-status-current-format "#[fg=#7aa2f7,bold]  #I #W #[fg=#bb9af7]"
      setw -g window-status-activity-style "fg=#e0af68"

      set -g remain-on-exit off
    '';
  };
}
