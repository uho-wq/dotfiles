{ config, pkgs, ... }:
{
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

  programs.lazygit = {
    enable = true;
    settings = {
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
