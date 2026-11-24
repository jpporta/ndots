{ ... }:

# macOS preferences shared by every Mac. Captured from velozient-mac; only
# values that differ from the macOS defaults (or are worth pinning) are listed.
# Not covered here (set by hand): locale/languages, keyboard input sources.
{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true; # auto light/dark
      AppleKeyboardUIMode = 2; # full keyboard navigation (Tab through controls)
      NSTableViewDefaultSizeMode = 1; # small sidebar icons
    };

    dock = {
      autohide = true;
      mru-spaces = false; # don't reorder Spaces by recent use (AeroSpace)
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv"; # column view
    };

    screencapture.target = "clipboard";

    # AeroSpace does the tiling; no extra margins from macOS tiling.
    WindowManager.EnableTiledWindowMargins = false;

    menuExtraClock = {
      ShowAMPM = true;
      ShowDayOfWeek = true;
      ShowDate = 0; # when space allows
    };

    hitoolbox.AppleFnUsageType = "Change Input Source"; # Globe key

    CustomUserPreferences = {
      NSGlobalDomain.AppleMiniaturizeOnDoubleClick = false;
      "com.apple.finder".FXPreferredGroupBy = "Kind";
      "com.apple.screencapture".showsClicks = true;
    };
  };
}
