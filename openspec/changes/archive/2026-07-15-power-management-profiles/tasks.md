## 1. State Management and Control Script

- [x] 1.1 Create the state directory `~/.local/state` if it doesn't exist.
- [x] 1.2 Create the control script `scripts/power-profile.sh`.
- [x] 1.3 Implement logic in the script to read and write the current profile to `~/.local/state/power-profile`.
- [x] 1.4 Implement `next` and `prev` logic to cycle through `normal`, `caffeinated`, and `headless`.
- [x] 1.5 Add logic to kill existing `swayidle` processes.
- [x] 1.6 Add logic to start `swayidle` with profile-specific arguments.
- [x] 1.7 Add logic to send a signal to Waybar to refresh the module (`pkill -RTMIN+8 waybar`).

## 2. NixOS and Home Manager Configuration

- [x] 2.1 Create a new Nix module `modules/power-profiles.nix` for the feature.
- [x] 2.2 In the module, define the three `swayidle` service configurations.
- [x] 2.3 Package the `power-profile.sh` script using `pkgs.writeShellScriptBin`.
- [x] 2.4 Add the script package to `home.packages`.
- [x] 2.5 Ensure the state directory is created using `home.file`.

## 3. Waybar Integration

- [x] 3.1 Add a `custom/power-profile` module to the Waybar configuration in `config/waybar/config`.
- [x] 3.2 Configure the module's `exec` to a script that reads the state file and outputs JSON with the correct icon and tooltip.
- [x] 3.3 Configure `on-click` to call `power-profile.sh next`.
- [x] 3.4 Configure `on-click-right` to call `power-profile.sh prev`.
- [x] 3.5 Add styles for the module in `config/waybar/style.css`.
- [x] 3.6 Define the real-time signal number for updates (e.g., `signal: 8`).

## 4. Hyprland Integration

- [x] 4.1 Add a keybinding to `config/hypr/hyprland.conf` to call `power-profile.sh next`.
- [x] 4.2 Add a keybinding to call `power-profile.sh prev`.

## 5. Verification

- [ ] 5.1 Rebuild the system with `home-manager switch`.
- [ ] 5.2 Verify that the Waybar module appears and shows the default `normal` state.
- [ ] 5.3 Test the keybindings to cycle through the profiles and observe the icon change.
- [ ] 5.4 Check that `swayidle` processes are restarted correctly with each profile change.
- [ ] 5.5 Verify the behavior of each profile (e.g., no suspension in `caffeinated` mode).
