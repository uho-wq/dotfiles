{ config, pkgs, lib, username, homeDirectory, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./tmux.nix
    ./tools.nix
    ./files.nix
  ];

  home = {
    username = lib.mkForce username;
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
