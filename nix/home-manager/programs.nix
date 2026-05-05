{ config, pkgs, ... }:
{
  # Git configuration
  programs.git = {
    enable = true;
    delta.enable = true;
    ignores = [
      ".DS_Store"
      ".envrc"
      "AGENTS.md"
      "init/"
      ".serena/"
      ".codex/"
      ".metals/"
      ".uho/"
      ".direnv/"
      ".claude/*.json"
      "settings.local.json"
    ];
    settings = {
      user = {
        name = "uho-wq";
        email = "58195776+uho-wq@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      core = {
        quotepath = false;
        excludesfile = "~/.config/git/ignore";
      };
      http.postBuffer = 524288000;
      ghq.root = "~/git";
      pull.rebase = true;
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 1000000;
      save = 1000000;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      watch = "watch -d ";
      ll = "ls -l";
      l = "\\ls -F --color=auto";
      ls = "ll -F --color=auto";
      sl = "ll -F --color=auto";
      lsa = "\\ls -Fa --color=auto";
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
      du = "du -h";
      diff = "colordiff -u";
    };

    initExtra = ''
      # Pure prompt
      autoload -U promptinit; promptinit
      prompt pure

      # Completion settings
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select

      # FZF options
      export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
        --highlight-line \
        --info=inline-right \
        --ansi \
        --layout=reverse \
        --border=none
        --color=bg+:#2d3f76 \
        --color=bg:#1e2030 \
        --color=border:#589ed7 \
        --color=fg:#c8d3f5 \
        --color=gutter:#1e2030 \
        --color=header:#ff966c \
        --color=hl+:#65bcff \
        --color=hl:#65bcff \
        --color=info:#545c7e \
        --color=marker:#ff007c \
        --color=pointer:#ff007c \
        --color=prompt:#65bcff \
        --color=query:#c8d3f5:regular \
        --color=scrollbar:#589ed7 \
        --color=separator:#ff966c \
        --color=spinner:#ff007c \
      "
      export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # History search with arrow keys
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^P" up-line-or-beginning-search
      bindkey "^N" down-line-or-beginning-search

      # Key bindings
      bindkey "^a" beginning-of-line
      bindkey "^e" end-of-line
      bindkey "^f" forward-char
      bindkey "^b" backward-char
      bindkey "^k" kill-line
      bindkey "^h" vi-backward-delete-char
      bindkey "^d" delete-char
      bindkey "^r" fzf-history-widget

      # FZF cd widget
      fzf-cd-widget() {
        local dir
        dir=$(find ''${1:-.} -maxdepth 3 -mindepth 1 \( -path '*/\.*' -prune \) \
                        -o -type d -print 2> /dev/null | fzf +m) &&
        if [[ -d "$dir" ]]; then
          cd "$dir"
          zle reset-prompt
        fi
      }
      zle -N fzf-cd-widget
      bindkey "^t" fzf-cd-widget

      # Ctrl-W stops at / and .
      my-backward-delete-word() {
          local WORDCHARS=''${WORDCHARS/\//}
          local WORDCHARS=''${WORDCHARS/\./}
          local WORDCHARS=''${WORDCHARS/\-/}
          zle backward-delete-word
      }
      zle -N my-backward-delete-word
      bindkey '^W' my-backward-delete-word

      # Auto ls on cd
      chpwd() {
          if [[ $(pwd) != $HOME ]]; then
              ls -al
          fi
      }

      # Git branch selector
      function select-git-branch-name() {
        target_br=$(
          git branch -a |
            fzf --exit-0 --layout=reverse --info=hidden --no-multi --preview-window="right,65%" --prompt="SELECT BRANCH > " --preview="echo {} | tr -d ' *' | xargs git log --color=always" |
            head -n 1 |
            perl -pe "s/\s//g; s/\*//g; s/remotes\/origin\///g"
        )
        if [ -n "$target_br" ]; then
          BUFFER="$BUFFER$target_br"
        fi
      }
      zle -N select-git-branch-name
      bindkey "^b" select-git-branch-name

      # ghq + fzf
      fzf-ghq-widget() {
        local selected_dir=$(ghq list -p | fzf --query "$LBUFFER" --prompt="SELECT REPOSITORY > ")
        if [ -n "$selected_dir" ]; then
          cd "$selected_dir"
          zle reset-prompt
        fi
      }
      zle -N fzf-ghq-widget
      bindkey "^y" fzf-ghq-widget

      # Shell options
      setopt NOCORRECT
      setopt AUTO_CD
      setopt AUTO_PARAM_KEYS
      setopt NO_BEEP
      setopt BANG_HIST
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_VERIFY
      setopt HIST_BEEP

      # Environment variables
      export VISUAL="nvim"
      export EDITOR="nvim"
      export CLICOLOR=1

      # Nix
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      # Cargo
      if [ -e "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      fi

      # PATH
      export PATH="$HOME/bin:$PATH:$HOME/.local/bin"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      export PATH="$HOME/.nodenv/shims:$HOME/.nodebrew/current/bin:$PATH"
      export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

      # Go
      export GOROOT="$HOME/sdk/go1.26.0"
      export GOPATH="$HOME/go"
      export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

      # Python (lazy load)
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      if command -v pyenv &> /dev/null; then
        pyenv() {
          unfunction pyenv
          eval "$(command pyenv init --path)"
          eval "$(command pyenv init -)"
          pyenv "$@"
        }
      fi

      # Bun
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"


      # Node (lazy load)
      if command -v nodenv &> /dev/null; then
        nodenv() {
          unfunction nodenv
          eval "$(command nodenv init - zsh)"
          nodenv "$@"
        }
      fi
    '';

    zsh-abbr = {
      enable = true;
      abbreviations = {
        g = "git";
        ga = "git add";
        gd = "git diff";
        gs = "git status --short";
        gc = "git commit -m";
        gcn = "git commit -nm";
        gp = "git pull";
        gsw = "git switch";
        c = "claude --enable-auto-mode";
				y = "yazi";
        lg = "lazygit";
        mk = "mkdir -p";
        o = "open .";
        a = "cd ../";
        aa = "cd ../../";
        aaa = "cd ../../../";
        aaaa = "cd ../../../../";
      };
    };
  };

  # Tmux configuration
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

  # Tool integrations
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.delta = {
    enable = true;
    options = {
      # Navigation & Layout
      navigate = true;
      side-by-side = false;
      line-numbers = true;
      hyperlinks = true;

      # Syntax theme (Nord is closest to Tokyo Night)
      syntax-theme = "Nord";

      # Tokyo Night colors
      # Red: #f7768e, Green: #9ece6a, Blue: #7aa2f7
      # Cyan: #7dcfff, Magenta: #bb9af7, Comment: #565f89

      # Diff styles
      minus-style = "syntax \"#4a1e2a\"";
      minus-emph-style = "bold syntax \"#8b2d3f\"";
      plus-style = "syntax \"#1e3a2a\"";
      plus-emph-style = "bold syntax \"#2d6b3d\"";

      # Line numbers
      line-numbers-minus-style = "#f7768e";
      line-numbers-plus-style = "#9ece6a";
      line-numbers-zero-style = "#565f89";

      # File header
      file-style = "#7aa2f7 bold";
      file-decoration-style = "#7aa2f7 ul";

      # Hunk header
      hunk-header-style = "file line-number syntax";
      hunk-header-decoration-style = "#565f89 box";
      hunk-header-line-number-style = "#e0af68";

      # Commit info
      commit-decoration-style = "#7aa2f7 box ul";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        editPreset = "nvim-remote";
      };
      customCommands = [
        {
          key = "o";
          context = "localBranches";
          command = "gh pr view -w";
          description = "Open PR in browser";
        }
        {
          key = "<c-a>";
          context = "files";
          output = "terminal";
          command = ''
           MSG=$(git diff --cached | claude --no-session-persistence --print --model haiku \
            'Generate ONLY a one-line Git commit message following Conventional Commits format \
            (type(scope): description). Types: feat, fix, docs, style, refactor, test, chore. \
            Based strictly on the diff from stdin. Output ONLY the message, nothing else.') \
            && git commit -e -m "$MSG"
          '';
        }
      ];
    };
  };

  programs.gh = {
    enable = true;
  };
}
