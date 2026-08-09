## 1. Add the Home Manager module

- [x] 1.1 Create `modules/home-manager/gif-recorder/default.nix` with `custom.gif-recorder.enable` and an enabled-only configuration.
- [x] 1.2 Install `wf-recorder`, `slurp`, `ffmpeg`, and `wl-clipboard` through the module and expose one `gif-recorder` script in the user's session path.
- [x] 1.3 Implement the toggle state under `XDG_RUNTIME_DIR`: start region selection/recording when idle, signal the active process on the second invocation, clean up on cancellation/interruption, and reject stale state.
- [x] 1.4 Finalize successful recordings with palette-based `ffmpeg` GIF encoding, timestamp the output below `~/Pictures/Screenshots`, and copy it with `wl-copy --type image/gif` while preserving the saved file if clipboard copy fails.

## 2. Wire the feature into the existing host

- [x] 2.1 Import `../../modules/home-manager/gif-recorder` and set `custom.gif-recorder.enable = true` in `hosts/jpporta-nixos/home.nix`.
- [x] 2.2 Add `SUPER + SHIFT + 5` to the existing `Screenshots` section of `modules/home-manager/hyprland/default.nix`, invoking `gif-recorder` so the same bind starts and stops the capture.

## 3. Verify the workflow

- [x] 3.1 Evaluate/build the `jpporta-nixos` Home Manager activation package and confirm the module and script parse successfully.
- [x] 3.2 Confirm the bind invokes the installed command and that the runtime dependency paths are available in the script.
- [ ] 3.3 In a live Hyprland session, select a region, stop with the same bind, and verify a timestamped GIF appears in `~/Pictures/Screenshots` and can be pasted from the Wayland clipboard.
- [ ] 3.4 Verify canceling `slurp`, stopping early, and an encoding failure leave no partial GIF and no stale runtime state.
