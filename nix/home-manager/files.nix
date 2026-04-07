{ config, pkgs, ... }:
let
  dotfilesPath = "${config.home.homeDirectory}/git/dotfiles";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    # Window manager configs
    ".skhdrc".source = symlink "${dotfilesPath}/skhd/skhdrc";
    ".yabairc".source = symlink "${dotfilesPath}/yabai/yabairc";

    # Claude config
    ".claude".source = symlink "${dotfilesPath}/claudecode";

    # WezTerm config
    ".config/wezterm".source = symlink "${dotfilesPath}/wezterm";

    # gh-dash config
    ".config/gh-dash".source = symlink "${dotfilesPath}/gh-dash";

    # Custom bin scripts
    "bin".source = symlink "${dotfilesPath}/bin";

    # Neovim config
    ".config/nvim".source = symlink "${dotfilesPath}/nvim";

    # vde-layout config
    ".config/vde/layout.yml".source = symlink "${dotfilesPath}/vde/layout.yml";
  };
}
