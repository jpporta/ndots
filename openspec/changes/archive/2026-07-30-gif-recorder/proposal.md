## Why

The Hyprland desktop has a screenshot flow but no equally convenient way to capture a short animated region of the screen. A Wayland-native GIF recorder should let the user select a region, press the same bind to stop, and receive the finished GIF in `~/Pictures/Screenshots` and on the clipboard.

## What Changes

- Add a new Home Manager module, `modules/home-manager/gif-recorder`, with a single enable option.
- Provide a Wayland-native recording script using `wf-recorder` and `slurp` to select and record a screen region.
- Toggle recording with one Hyprland bind: the first press starts region selection/recording and the next press stops it.
- Convert the recording to an optimized GIF after stopping.
- Save completed GIFs under `~/Pictures/Screenshots` with timestamped filenames.
- Copy the completed GIF to the Wayland clipboard for immediate pasting.
- Enable the module from `hosts/jpporta-nixos/home.nix` and add only the required bind in the existing Hyprland Home Manager module.

## Capabilities

### New Capabilities

- `gif-recorder`: Select, toggle-record, save, and clipboard-copy short Wayland screen-region GIFs.

### Modified Capabilities

- None.

## Impact

- New Home Manager module and user-facing recording script.
- Existing `modules/home-manager/hyprland/default.nix` gains the toggle bind.
- `hosts/jpporta-nixos/home.nix` imports and enables the module.
- Adds the runtime packages `wf-recorder`, `slurp`, `ffmpeg`, and a Wayland clipboard utility through the module.
- Creates `~/Pictures/Screenshots` when a recording is completed; existing screenshot behavior remains unchanged.
