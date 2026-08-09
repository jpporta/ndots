## 1. Module and State Foundation

- [x] 1.1 Create a reusable Home Manager module with a disabled-by-default `custom.alarms-timers.enable` option.
- [x] 1.2 Define the XDG state path, JSON event schema, numeric ID allocation, atomic writes, and file-locking helpers.
- [x] 1.3 Add strict parsing and normalization for timer durations, local times, explicit dates, and optional descriptions.
- [x] 1.4 Add `timer` and `alarm` command entry points for creation, validation errors, and ID output.

## 2. Listing and Cancellation

- [x] 2.1 Implement `timer list` and `alarm list` with deadline ordering, IDs, descriptions, and empty-state output.
- [x] 2.2 Implement `timer cancel ID` and `alarm cancel ID` with type checking and unknown-ID errors.
- [x] 2.3 Add focused shell-level checks for creation, time-only rollover, explicit-date rejection, duplicate alarms, listing, cancellation, and malformed input.

## 3. Scheduler and Completion Effects

- [x] 3.1 Implement the user scheduler loop with one-second wall-clock checks and serialized state access.
- [x] 3.2 Remove events missed while the scheduler or computer was unavailable without notifying.
- [x] 3.3 Remove an observed due event before running completion effects so failures cannot duplicate notifications.
- [x] 3.4 Send one critical `notify-send` notification with type, deadline, and optional description.
- [x] 3.5 Package or reference a freedesktop sound-theme file and play it once for approximately one second through `pw-play`.
- [x] 3.6 Define and enable the systemd user service on the graphical session, with restart behavior that does not replay missed events.
- [x] 3.7 Add scheduler checks for due events, missed events, duplicate prevention, notification failure, and concurrent state mutation.

## 4. Home Manager Integration

- [x] 4.1 Install the CLI, scheduler, Waybar helper, `jq`, PipeWire playback dependency, and sound theme through the reusable module.
- [x] 4.2 Enable the module in `hosts/jpporta-nixos/home.nix` without enabling it for other hosts.
- [x] 4.3 Add state-directory initialization and verify the generated user service and executable paths.
- [x] 4.4 Evaluate and build the `jpporta-nixos` configuration to catch Nix/module errors.

## 5. Waybar Integration

- [x] 5.1 Implement `alarm-waybar` JSON output with global deadline ordering and a maximum of three entries.
- [x] 5.2 Format timers as `HH:MM` above one minute and seconds below one minute; format alarms as fixed local `HH:MM` times.
- [x] 5.3 Add safely escaped descriptions to Waybar tooltips and emit empty text when no events exist.
- [x] 5.4 Update `~/dotfiles/waybar/.config/waybar/config.jsonc` with `custom/alarm` immediately after workspaces, one-second refresh, JSON return type, and no click actions.
- [x] 5.5 Update the Waybar stylesheet selector for the new module and verify it matches the existing visual treatment.
- [x] 5.6 Reload Waybar and manually verify mixed timer/alarm ordering, three-item truncation, countdown updates, tooltip content, and hidden empty state.

## 6. End-to-End Verification

- [x] 6.1 Create representative timers and alarms from a terminal and verify IDs, list output, duplicate rejection, and cancellation.
- [x] 6.2 Verify a due event produces exactly one critical SwayNC notification and one short PipeWire sound.
- [x] 6.3 Verify scheduler restart or system resume removes missed events without producing late notifications.
- [x] 6.4 Verify the final Nix build and Waybar configuration together on `jpporta-nixos`.
