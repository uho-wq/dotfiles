{ pkgs, ... }:
{
  imports = [
    ./system.nix
    ./homebrew.nix
    ./time.nix
    ./fonts.nix
    ./users.nix
    ./security.nix
    ./nix.nix
  ];
}
