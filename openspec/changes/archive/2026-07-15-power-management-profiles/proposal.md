## Why

Users need a quick way to switch between different power management configurations on their system depending on the task at hand. For example, a "caffeinated" mode is needed to prevent the system from sleeping during presentations or long-running tasks, while a "headless" mode is useful for running the machine as a server, and a "normal" mode for everyday desktop use.

## What Changes

- A script will be created to manage three power management profiles: `caffeinated`, `headless`, and `normal`.
- A Waybar module will be added to display the current power profile.
- A Hyprland keybinding will be configured to cycle through the power profiles.

## Capabilities

### New Capabilities
- `power-profile-management`: Manages power-saving settings for different operational modes, including screen blanking, locking, and system suspension. It also provides a visual indicator for the current mode in the Waybar status bar.

### Modified Capabilities
- None

## Impact

- **Code:** New Nix code for the power management script and Waybar/Hyprland configuration.
- **System:** Affects system-wide power settings managed by `swayidle` or a similar service.
- **User Interface:** A new module will appear in the Waybar status bar.
