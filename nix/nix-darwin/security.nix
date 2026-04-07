{ pkgs, ... }:
{
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;  # Enable Touch ID in tmux
  };
}
