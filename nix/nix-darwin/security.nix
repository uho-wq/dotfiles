{ pkgs, ... }:
{
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;  # Enable Touch ID in tmux
  };

  # eMudhra 中間CA秘密鍵漏洩 (2026-10-20) の暫定対処。
  # nixpkgs の cacert 3.131.1 が nixos-unstable に入ったら外してよい。
  # https://emudhra.we-have-a-problem.com/
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
