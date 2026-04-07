{ pkgs, username, ... }:
{
  networking = {
    hostName = "uho";
  };

  system = {
    stateVersion = 6;
    primaryUser = username;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.001;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          "com.apple.mouse.scaling" = 3.0;
          NSQuitAlwaysKeepsWindows = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
        };
        "com.apple.finder" = {
          FXArrangeGroupViewBy = "Date Modified";
          FXPreferredGroupBy = "Date Modified";
        };
      };

      WindowManager = {
        StandardHideDesktopIcons = true;
      };

      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = false;
        Bluetooth = false;
      };

      dock = {
        autohide = true;
        largesize = 40;
        magnification = true;
        orientation = "bottom";
        show-recents = false;
        static-only = true;
        tilesize = 32;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowRemovableMediaOnDesktop = false;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 0;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };

      spaces = {
        spans-displays = false;
      };
    };
  };

  programs.zsh.enable = true;
}
