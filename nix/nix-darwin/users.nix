{ pkgs, username, homeDirectory, ... }:
{
  users.users.${username} = {
    home = homeDirectory;
    shell = pkgs.zsh;
  };
}
