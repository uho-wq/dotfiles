{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.symbols-only
      # Note: Cica font is managed via Homebrew (font-cica)
    ];
  };
}
