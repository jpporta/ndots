## Context

The desktop already uses Home Manager modules under `modules/home-manager` and keeps Hyprland keybinds in `modules/home-manager/hyprland/default.nix`. The new capability is a small user-session workflow, not a daemon: select a region with `slurp`, record it with the Wayland-native `wf-recorder`, encode the result with `ffmpeg`, and publish the finished file with `wl-copy`.

The same Hyprland bind must start and stop the workflow. The first invocation needs to remain alive while recording; a later invocation needs a stable way to find and signal that process. The implementation also needs to avoid leaving partial files in the screenshots directory when selection is cancelled or encoding fails.

## Goals / Non-Goals

**Goals:**

- Encapsulate packages, script, option, output directory, and runtime state in `modules/home-manager/gif-recorder`.
- Use a single toggle command suitable for a Hyprland `bind`.
- Select a rectangular region interactively through `slurp`.
- Save optimized GIF output in `~/Pictures/Screenshots` and copy it as `image/gif` with `wl-copy`.
- Keep host wiring minimal: import/enable in `hosts/jpporta-nixos/home.nix`, bind in the existing Hyprland module.

**Non-Goals:**

- Full-screen or window recording modes.
- A recording history, notification UI, configurable encoder settings, or a separate stop bind.
- A new service or background daemon.
- Changes to the existing screenshot flow.

## Decisions

### D1. One shell script owns the toggle state

The module installs one `gif-recorder` executable and uses a runtime-directory state file containing the active script PID. If the state file names a live process, a new invocation sends it `SIGINT`; otherwise it runs `slurp` and starts a recording. This keeps the bind to one command and avoids adding a service or IPC layer.

**Alternative:** use separate start/stop scripts or a systemd user service. Rejected because they add commands and lifecycle machinery for one short-lived action.

### D2. Use `wf-recorder`, `slurp`, `ffmpeg`, and `wl-copy`

These tools are small, composable Wayland utilities already suited to the requested flow. `wf-recorder` receives the geometry selected by `slurp`; `ffmpeg` handles palette generation and GIF encoding; `wl-copy --type image/gif` makes the resulting file available to Wayland clipboard consumers.

**Alternative:** OBS or a screenshot/GIF application. Rejected because a GUI recorder is heavier than the requested Hyprshot-like interaction.

### D3. Encode through a temporary video file

Recording first to a temporary Matroska file keeps the output atomic: the final timestamped GIF is moved into `~/Pictures/Screenshots` only after `ffmpeg` succeeds. The encoder uses a palette-generation filter and a bounded frame rate/width to avoid the worst GIF size and color-quality problems without introducing configuration options.

**Alternative:** record directly to GIF. Rejected because palette generation and interruption handling are worse, and `wf-recorder` is designed primarily for video output.

### D4. Store state under `XDG_RUNTIME_DIR`

The state file belongs in `${XDG_RUNTIME_DIR:-/tmp}` and is removed on normal completion or cancellation. It is session-local and avoids polluting the home directory with a lock file.

## Risks / Trade-offs

- [GIFs are inherently large and limited to 256 colors] -> Cap output at a modest frame rate and width; keep the original temporary recording out of the screenshots directory.
- [A crashed process can leave a stale state file] -> Check whether the recorded PID is alive before treating the workflow as active, and remove stale state before starting.
- [Clipboard consumers differ in GIF support] -> Publish with the explicit `image/gif` MIME type; the saved file remains the fallback when a consumer cannot paste animated images.
- [The second bind may be pressed while region selection is active] -> Keep the controlling script PID in the state file before invoking `slurp`, and handle interruption by cleaning up without creating output.

## Migration Plan

1. Apply the Home Manager configuration for `jpporta-nixos`.
2. Press the new Hyprland bind and select a region; press it again to stop and wait for encoding.
3. Verify the GIF in `~/Pictures/Screenshots` and paste it into a GIF-capable Wayland application.
4. Roll back by disabling/removing the module import and bind; no persistent data migration is required, and existing GIF files are left untouched.

## Open Questions

- The exact key combination should follow the existing screenshot bind convention in the Hyprland module; implementation should reuse that convention rather than introduce a new modifier scheme.
