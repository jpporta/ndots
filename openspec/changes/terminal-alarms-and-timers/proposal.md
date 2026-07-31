## Why

The desktop currently has no quick, reliable way to schedule short-lived timers or wall-clock alarms from a terminal. A local command-line scheduler would make these events available from any shell while keeping their status visible in the existing Waybar and using the existing SwayNC/PipeWire desktop stack for completion alerts.

## What Changes

- Add reusable Home Manager support for `timer` and `alarm` commands.
- Persist unlimited active timers and alarms with numeric IDs.
- Support timer durations, time-only alarms, dated alarms, optional descriptions, listing, cancellation, and duplicate alarm prevention.
- Add a user-level scheduler that fires due events once, skips events missed while the computer is unavailable, and survives the terminal closing.
- Send one critical desktop notification and play a one-second PipeWire sound when an event fires.
- Add a Waybar JSON module that refreshes every second and displays the three closest active events across both event types.
- Integrate the module into the external Waybar configuration at `~/dotfiles/waybar/.config/waybar/`, immediately after workspaces in `modules-left`.
- Exclude recurring alarms, snoozing, pause/resume, graphical management, and Waybar click actions.

## Capabilities

### New Capabilities

- `terminal-alarms-and-timers`: Create, persist, inspect, cancel, schedule, and complete terminal timers and wall-clock alarms, including their Waybar status display.

### Modified Capabilities

<!-- No existing capability requirements change. -->

## Impact

- Adds a reusable Home Manager module under `modules/home-manager/` and enables it for `jpporta-nixos` only.
- Adds user-facing commands, persisted state under `~/.local/state`, and a systemd user service.
- Uses existing `jq`, `notify-send`/SwayNC, PipeWire, and Waybar conventions; adds the freedesktop sound theme if needed for the completion sound.
- Updates the separately managed Waybar config and stylesheet under `~/dotfiles/waybar/.config/waybar/`.
- No network services, database, external API, or system-wide daemon is introduced.
