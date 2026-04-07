{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    delta.enable = true;
    ignores = [
      ".DS_Store"
      ".envrc"
      "CLAUDE.md"
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

  programs.delta = {
    enable = true;
    options = {
      # Navigation & Layout
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      hyperlinks = true;

      # Syntax theme (Nord is closest to Tokyo Night)
      syntax-theme = "Nord";

      # Tokyo Night colors
      # Red: #f7768e, Green: #9ece6a, Blue: #7aa2f7
      # Cyan: #7dcfff, Magenta: #bb9af7, Comment: #565f89

      # Diff styles
      minus-style = "syntax \"#37222c\"";
      minus-emph-style = "syntax \"#713137\"";
      plus-style = "syntax \"#20303b\"";
      plus-emph-style = "syntax \"#2b5a47\"";

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
}
