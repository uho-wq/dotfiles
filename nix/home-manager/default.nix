{ config, pkgs, lib, username, homeDirectory, arto-pkg, ... }:
{
  imports = [
    ./programs.nix
    ./files.nix
  ];

  home = {
    username = lib.mkForce username;
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = "24.05";
    packages = [ arto-pkg ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
