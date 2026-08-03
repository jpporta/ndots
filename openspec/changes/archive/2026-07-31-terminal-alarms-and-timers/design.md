## Context

The desktop runs NixOS with Home Manager, Hyprland, Waybar, SwayNC, and PipeWire. Existing Home Manager modules install shell applications with `writeShellApplication`, define user services, and expose state-backed Waybar scripts. The Waybar layout is maintained separately in `~/dotfiles/waybar/.config/waybar/`; it already has JSON custom modules, a one-second-compatible refresh pattern, and a left-side sequence containing workspaces.

The feature needs one persistent source of truth shared by interactive commands, a scheduler, and Waybar. It must remain local, tolerate concurrent command/scheduler access, and avoid replaying events missed while the machine was unavailable.

## Goals / Non-Goals

**Goals:**

- Provide `timer` and `alarm` commands with creation, listing, and ID-based cancellation.
- Persist unlimited events and calculate absolute local wall-clock deadlines.
- Run scheduling as a user service independent of the terminal that created an event.
- Deliver one critical SwayNC notification and one-second PipeWire sound per completed event.
- Provide a reusable Waybar JSON helper showing the three nearest active events.
- Enable the Home Manager module only on `jpporta-nixos` initially.

**Non-Goals:**

- Recurring alarms, snooze, pause/resume, labels, graphical management, or click actions.
- A database, network service, system-wide daemon, or cross-host synchronization.
- Managing the complete external dotfiles repository from this Nix repository.

## Decisions

### 1. Use one JSON state file

Store active events and the next numeric ID in `~/.local/state/alarm/events.json`. Each event contains an ID, kind, absolute due timestamp, and optional description. JSON keeps the state inspectable and lets the existing `jq` package handle parsing without adding a runtime dependency.

Writes use a temporary file followed by an atomic rename. Command and scheduler mutations use a user-level file lock so a cancellation cannot race with a firing event or another creation.

**Alternative considered:** SQLite. Rejected because this is a single-user local state file with no query volume or relational data; SQLite would add setup and migration overhead.

### 2. Use one CLI executable with `timer` and `alarm` entry points

Install a shared implementation and expose the requested commands. `timer DURATION`, `timer list`, and `timer cancel ID` manage timers. `alarm [DATE] TIME [DESCRIPTION...]`, `alarm list`, and `alarm cancel ID` manage alarms. Numeric IDs make cancellation unambiguous when unlimited events exist.

Durations support a single positive numeric value with a unit such as `s`, `m`, or `h`. Time-only alarms resolve to the next occurrence in local time. Explicit dated alarms use the supplied date and are rejected when already in the past. Alarm creation rejects an existing alarm with the same normalized timestamp.

**Alternative considered:** A single `alarm set` command. Rejected because it would not preserve the requested ergonomic `timer 10m` and `alarm 15:10` commands.

### 3. Use a polling user service for scheduling

The scheduler runs under `systemd --user`, checks state once per second, and removes events whose deadlines were missed while the service or computer was unavailable. It fires an event only when the scheduler observes the event at or after its deadline without having previously missed it. After firing, it removes the event before sending completion effects, preventing duplicate notifications if the effect command fails.

**Alternative considered:** One systemd timer unit per event. Rejected because unlimited dynamic units complicate creation, cancellation, cleanup, and missed-event semantics. A single small scheduler is easier to reason about and sufficient for a personal desktop.

### 4. Reuse the existing desktop notification and audio stack

Completion uses `notify-send` with critical urgency so SwayNC applies its existing critical styling. It plays a one-second sound through `pw-play`, using a packaged freedesktop sound-theme file. Notification and sound failures do not restore or duplicate the already-completed event.

**Alternative considered:** Terminal bell only. Rejected because terminal bells depend on the terminal and may be disabled or inaudible outside the originating shell.

### 5. Make Waybar a read-only state consumer

`alarm-waybar` reads active state, removes invalid/stale entries from its output without mutating the scheduler state, sorts timers and alarms by due timestamp, and emits JSON for the three closest entries. It emits an empty text value when there are no active events, allowing Waybar to hide the module. Timer text uses `HH:MM` above one minute and seconds below one minute; alarms use fixed local `HH:MM` time. Descriptions appear in escaped tooltips.

The external Waybar config adds `custom/alarm` directly after `hyprland/workspaces` in `modules-left`, with `interval: 1`, JSON return type, and no click handlers. The external stylesheet adds the module to the existing shared module selector.

### 6. Package the feature as a reusable Home Manager module

The module owns the CLI, scheduler, Waybar helper, state directory setup, sound theme dependency, and user service. `hosts/jpporta-nixos/home.nix` imports and enables it. Other hosts remain unaffected until they explicitly enable the option.

## Risks / Trade-offs

- **[One-second polling consumes a small amount of CPU]** → Keep the scheduler as a single process with a one-second sleep and use the same interval only for the Waybar helper; avoid one process per event.
- **[System time changes can move deadlines]** → Store absolute local timestamps and compare against the current wall clock on every loop; document that manual clock changes affect pending events.
- **[Concurrent state updates can lose events]** → Serialize mutations with a lock and write state atomically through a temporary file.
- **[A sound file may be unavailable on a different host]** → Package the freedesktop sound theme with the module and make audio playback best-effort while still sending the notification.
- **[Waybar lives in a separate repository]** → Keep the generated helper in ndots, make the external config edit explicit in the task list, and verify both repositories independently.
- **[Descriptions may contain shell-sensitive or JSON-sensitive characters]** → Treat descriptions as data, avoid shell interpolation of user text, and JSON-escape all Waybar and notification fields.

## Migration Plan

1. Enable the new Home Manager module on `jpporta-nixos` and rebuild the user environment.
2. Add the `custom/alarm` module and CSS selector to `~/dotfiles/waybar/.config/waybar/`.
3. Start or reload Waybar and the user scheduler through the normal Hyprland session.
4. Verify creation, listing, cancellation, Waybar refresh, completion notification, sound, duplicate rejection, and missed-event cleanup.
5. Roll back by disabling the module, removing the Waybar entry, and deleting the optional state directory if the user wants to discard pending events.

## Open Questions

- None blocking implementation. Explicit dated alarms are defined to reject past timestamps; only time-only alarms roll forward to the next day.
