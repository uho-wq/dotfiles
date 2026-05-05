{ nixpkgs, system, neovim-nightly-overlay }:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      neovim-nightly-overlay.overlays.default
      (final: prev:
        let
          golangci-lint-src = prev.fetchFromGitHub {
            owner = "golangci";
            repo = "golangci-lint";
            rev = "v2.7.2";
            hash = "sha256-8dVIWa+yFvuBz2yXcPG1cBkxltqdjlb+tmQ+AtYuicc=";
          };
        in
        {
          golangci-lint = prev.golangci-lint.overrideAttrs (old: {
            version = "2.7.2";
            src = golangci-lint-src;
            goModules = (old.goModules.overrideAttrs {
              src = golangci-lint-src;
              outputHash = "sha256-MHz9VQvObHkvf62HNcPGfsskv5RJpe6g23CoXHOGUZc=";
            });
          });
        }
      )
    ];
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "zsh-abbr"
      ];
  };
in
{
  inherit pkgs;

  uho = pkgs.buildEnv {
    name = "uho";
    pathsToLink = [ "/bin" "/share" ];
    paths = with pkgs; [
      git
      curl
      neovim
      fzf
      bat
      ripgrep
      gh
      gh-dash
      gh-poi
      fd
      jq
      lazygit
      tmux
      tree
      wget
      yazi
      zoxide
      ghq
      gitleaks
      lefthook
      watch
      awscli2
      colordiff
      coreutils
      direnv
      gnupg
      gpgme
      libassuan
      lf
      marp-cli
      mkcert
      mysql84
      pnpm
      pyenv
      rbenv
      tree-sitter
      universal-ctags
      neovim-remote
      pure-prompt
      zsh-autosuggestions
      zsh-completions
      zsh-syntax-highlighting
      jnv
      uv
    ];
  };
}
