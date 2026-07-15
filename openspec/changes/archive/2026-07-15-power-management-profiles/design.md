## Context

Currently, the system uses a default power management configuration. There is no easy way for the user to switch between different power-saving modes for different use cases, such as presenting, running a headless server, or normal desktop usage.

## Goals / Non-Goals

**Goals:**
- Implement a script to control power management settings.
- Define three distinct power profiles: `caffeinated`, `headless`, and `normal`.
- Integrate the script with Hyprland for key-based switching.
- Provide visual feedback of the current profile in the Waybar status bar.
- Manage the entire configuration using Nix and Home Manager.

**Non-Goals:**
- Creating a graphical user interface for configuration.
- Supporting operating systems other than NixOS.
- Supporting display managers other than Wayland/Hyprland.

## Decisions

1.  **State Management**: A state file at `~/.local/state/power-profile` will store the name of the currently active profile (e.g., `caffeinated`). This simple approach allows the control script and Waybar module to easily share the current state.

2.  **Control Script**: A `bash` script will be the core of this feature. It will accept arguments like `next`, `prev`, or a specific profile name (`caffeinated`, `headless`, `normal`). When called, it will:
    a. Update the state file.
    b. Kill any existing `hypridle` process.
    c. Start a new `hypridle` process with the configuration corresponding to the selected profile.
    d. Send a signal to Waybar to refresh the module (`pkill -RTMIN+8 waybar`).

3.  **Power Management Daemon**: `hypridle` will be used to manage idle events. We will define three separate service configurations for it, one for each profile, with different timeouts for screen blanking (`hyprlock`), and system suspension.
    - **Caffeinated**: No timeouts. `hypridle` will run with no events configured.
    - **Headless**: Timeout for screen blanking and locking, but no suspend action.
    - **Normal**: Default timeouts for screen blanking, locking, and suspension.

4.  **Waybar Module**: A `custom/power-profile` module in Waybar will be used.
    - It will use Waybar's `on-click` functionality to call the control script to cycle profiles.
    - It will execute a small script (`exec`) that reads the state file and outputs JSON with an icon representing the current state (e.g., `{"text": "", "tooltip": "Profile: Caffeinated"}`).
    - The module will update automatically when it receives a real-time signal, which the control script will send.

5.  **Hyprland Keybinding**: A `bind` entry in `hyprland.conf` will be added to call the control script to cycle through the profiles, e.g., `bind = $mainMod, BRACKETRIGHT, exec, ~/dotfiles/scripts/power-profile.sh next`.

## Risks / Trade-offs

- **[Risk]** The `pkill hypridle` command could potentially interfere with other user-started `hypridle` instances if they exist.
- **Mitigation**: This is unlikely in a typical user session. The script will be part of a managed dotfiles configuration where only one instance is expected.
- **Mitigation**: `systemctl --user restart hypridle.service` should restart hypridle with new configuration

- **[Trade-off]** Using a state file on disk introduces a small amount of I/O and a potential point of failure if file permissions are incorrect.
- **Rationale**: This is a simple and reliable IPC mechanism for this use case, preferable to more complex solutions. The file will be managed by Home Manager, ensuring correct permissions.
