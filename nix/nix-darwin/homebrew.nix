{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
    caskArgs = {
      appdir = "~/Applications";
    };
    taps = [
      "ariga/tap"
      "daipeihust/tap"
      "FelixKratz/formulae"
      "koekeishiya/formulae"
      "tonisives/tap"
      "databricks/tap"
    ];
    brews = [
      # Node.js version managers (not in Nixpkgs)
      "node-build"
      "nodebrew"
      "nodenv"
      # Terraform version manager (not in Nixpkgs)
      "tfenv"
      # Specific versions
      "mysql-client@8.0"
      # Window management
      "lefthook"
      "pre-commit"
      # Databricks CLI
      "databricks/tap/databricks"
      "promptfoo"
    ];
    casks = [
      "1password"
      "1password-cli"
      "docker-desktop"
      "google-chrome"
      "google-japanese-ime"
      "google-drive"
      "gcloud-cli"
      "raycast"
      "wezterm"
      "cleanmymac"
      "cmd-eikana"
      "dbeaver-community"
      "font-cica"  # Cica is not in nixpkgs, keep in Homebrew
      "font-symbols-only-nerd-font"
      "obsidian"
      "sequel-ace"
      "slack"
      "zoom"
      "bettertouchtool"
      "chromium"
      "spotify"
      "copilot-cli"
    ];
  };
}
