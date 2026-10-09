# Plan — split one virtual sink to two hardware sinks

## 1. Request
Create a new virtual output device (sink). Any stream played into it must be
mirrored to two hardware sinks simultaneously, so the user hears the same audio
on two devices at once.

**Decisions agreed with the user:**
- Target hardware sinks: **DX1 Headphones** + **USB Audio Speakers**.
- Mechanism: **on-demand toggle script** (mirrors the existing `virtual-mic`
  pattern), not an always-on WirePlumber node.

## 2. Target
- Host: `jpporta-nixos` (user environment, Home Manager).
- Scope of edited files (see §5). This is a Home Manager change only; no NixOS
  system target touched. The new module is host-local (imported only by
  `hosts/jpporta-nixos/home.nix`), so it does **not** affect `jpporta-deck`.

## 3. Current behavior
- PipeWire + WirePlumber + Pulse compat are enabled in
  `hosts/jpporta-nixos/configuration.nix` (`services.pipewire`, pulse and
  wireplumber enabled; `pulseaudio.enable = false`).
- `modules/home-manager/audio-rate/default.nix` already ships a `virtual-mic`
  script that creates a `module-null-sink`, a `module-loopback`, and a
  `module-remap-source` via `pactl`. This proves the null-sink + loopback
  approach works on this machine and gives a pattern to mirror.
- Current Pulse sinks (from `wpctl status` / `pw-cli ls Node`):
  - `DX1 Headphones` — node.name `alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink` (current default).
  - `USB Audio Speakers` — node.name `alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink`.

## 4. Desired behavior
- A new script `audio-split` with subcommands `start|stop|status|toggle`
  (matching the `virtual-mic` interface).
- `start`:
  1. Create a null sink `split_combined` (description "Combined Output").
  2. Create loopback 1: `source=split_combined.monitor` → `sink=<DX1 Headphones>`.
  3. Create loopback 2: `source=split_combined.monitor` → `sink=<USB Audio Speakers>`.
  4. Print the instructions to select "Combined Output" as the default sink.
- `stop`: unload the two loopbacks and the null sink.
- `status`: report whether the combined sink is running.
- Both object groups (loopback and sink) are tracked by module id via `pactl
  list short modules`, exactly like `virtual-mic`, so `start` is idempotent and
  `stop` is clean.

### Sink reference strategy
- Hardware sinks are referenced by their stable Pulse node names (the
  `alsa_output...` strings above). The two names are hardcoded as variables at
  the top of the script for easy editing.
- If either hardware sink is missing at `start` time (device unplugged), the
  script aborts with a clear error before creating anything, so no half-built
  graph is left behind.

## 5. Files and edits
1. **New** `modules/home-manager/audio-split/default.nix`
   - Declares `options.custom.audio-split.enable = lib.mkEnableOption ...`.
   - Defines `audioSplitScript = pkgs.writeShellApplication { name = "audio-split"; ... }`
     (runtime inputs: `coreutils`, `gnugrep`, `gawk`, `pulseaudio` — same set as
     `virtual-mic`).
   - `config = lib.mkIf cfg.enable { home.packages = [ audioSplitScript ]; };`
2. **Edit** `hosts/jpporta-nixos/home.nix`
   - Add `../../modules/home-manager/audio-split` to `imports`.
   - Add `audio-split.enable = true;` to the enable block (next to
     `audio-rate.enable = true;`).

No edits to `configuration.nix`, shared modules, or the deck host.

## 6. Validation approach
- Build only (no switch) first: `sudo nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos`
  (or `nixos-rebuild build --flake ~/ndots#jpporta-nixos`) to confirm the eval
  and script derivation compile.
- After approval of the switch, deploy with
  `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`, then:
  - `audio-split start`
  - `wpctl status` shows a new "Combined Output" sink.
  - Play a test tone / stream into that sink and confirm audio is audible on
    both DX1 Headphones and USB Speakers.
  - `audio-split stop` removes the sink and loopbacks.
  - `audio-split start` again (idempotency check).

## 7. Risks
- **USB hotplug**: if either device is unplugged the sink disappears; the script
  handles this by failing fast on `start`. Re-running `start` after reconnecting
  rebuilds it. (Accepted limitation; no udev/event wiring in this change.)
- **Latency**: two extra loopbacks add a small, fixed latency (`latency_msec=20`,
  same as `virtual-mic`). Acceptable for desktop audio mirroring.
- **Name collisions**: `split_combined` could collide with a user-created sink of
  the same name; unlikely, and `start` guards by checking existence first.
- **No rollback risk to existing config**: this only adds a new module + one
  import + one enable flag; disabling is `audio-split.enable = false;`.

## 8. Rollback
- `git checkout` / revert the two files, or set `audio-split.enable = false;`.
- At runtime: `audio-split stop` (or `pactl unload-module <id>` on the listed
  modules) removes the sink without touching the hardware sinks.

## 9. Deployment command
- `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Approval — plan
- **Approved by:** jpporta (owner)
- **Granted:** "approved"
- **Date:** 2026-10-09 19:11
- **Scope:** investigation plan (§1–§9) — proceed to implementation.