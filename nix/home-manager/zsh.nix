{ config, pkgs, ... }:
{
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
        c = "CLAUDE_CODE_NO_FLICKER=1 claude --enable-auto-mode";
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
}
