## Why

The current swaync styling is hardcoded in `modules/home-manager/swaync/default.nix` with a single gruvbox palette and a flat, square-ish look. The user wants a new "Groovebox" theme that feels like iOS notifications — glassy, rounded, with an app icon, title, truncated body, and a small timestamp — and a notification tray that pops from the bottom-left corner. Notification urgency (`low` / `normal` / `critical`) should drive the title color and the border accent so the priority is readable at a glance. The existing swaync Nix module also bakes its colors into the store, which is the pattern the archived `theme-switch` change set out to undo; this change finishes that work for swaync by moving the stylesheet + colors into `~/.config/colorschemes/groovebox/swaync/` so future themes are dotfiles, not Nix edits.

## What Changes

- **NEW** `~/.config/colorschemes/groovebox/` theme directory with a `swaync/` subdir containing `style.css` (iOS-style layout) and `colors.css` (the Groovebox palette).
- **NEW** `swaync` Nix module is thinned down: it drops the inline `style.css` block and switches to sourcing `~/.config/swaync/style.css` + `colors.css` from the active theme dir via `xdg.configFile` + `lib.file.mkOutOfStoreSymlink` (the same pattern the archived theme-switch change planned).
- **MODIFIED** `modules/home-manager/swaync/default.nix` settings: `positionX = "left"`, `positionY = "bottom"`, `notification-window-width` widened, `transition-time` bumped for the slide-up feel, and any other layout knobs needed for the iOS look.
- **NEW** stylesheet implements iOS aesthetic: rounded glass cards (large border-radius, bg with alpha + blur-friendly shadow), horizontal layout (icon left, title + body right), title color follows urgency (low = cyan, normal = white, critical = red), border accent matches title color, top-right timestamp in small caps, control center tray is blackish with the same glass treatment, notification close button is a chip in the top-right.
- **NEW** `~/.config/colorschemes/groovebox/swaync/colors.css` defines the Groovebox palette: dark base (`#14171c` background, `#1a1d24` card), light text (`#e6e6e6`), and a set of vibrant accent colors for urgency (red `#ff5e7a`, amber `#f5a623`, green `#5fe1a7`, cyan `#5cd6ff`, purple `#b58cff`).
- **MODIFIED** `hosts/jpporta-nixos/home.nix` keeps `services.swaync.enable = true;` (no host-side change required beyond the module rewrite).
- **NOTE** the per-theme symlink swap + `swaync-client --reload-css` reload mechanism is owned by the (still-pending) `theme-switch` change. This change ships Groovebox as the **first** theme under the new layout so `theme-switch groovebox` works once that script lands; the theme-switch script itself is **not** in scope here.

## Capabilities

### New Capabilities

- `swaync-groovebox-theme`: the iOS-styled swaync theme (Groovebox palette + new layout) shipped as the first theme under the `~/.config/colorschemes/<theme>/swaync/` layout.

### Modified Capabilities

- None. Existing `power-profile-management` spec is unrelated. The archived `theme-colors-sources` spec from `2026-07-13-theme-switch` is **not** a current `openspec/specs/` entry, so it isn't a "modified" target — but the intent of D4 there (swaync reads colors from the active theme dir, not from Nix) is satisfied for the Groovebox theme by this change.

## Impact

- **Code:**
  - `modules/home-manager/swaync/default.nix` — thin: drop the inline `style.css`, point `xdg.configFile."swaync/style.css"` and `xdg.configFile."swaync/colors.css"` at out-of-store symlinks to `~/.config/colorschemes/.active/swaync/`.
  - `~/.config/colorschemes/groovebox/swaync/style.css` — new (iOS layout).
  - `~/.config/colorschemes/groovebox/swaync/colors.css` — new (Groovebox palette).
  - `~/.config/colorschemes/groovebox/meta` — new (`name=Groovebox\nmode=dark`) for future `theme-picker` compatibility.
- **System:** `swaync-client --reload-css` becomes the live-reload path (no `home-manager switch` on tweaks). The symlink target depends on `~/.config/colorschemes/.active` being a symlink to `groovebox`; this is **not** implemented by this change (it's the `theme-switch` change's job) but the dotfiles are laid out so that one command sets it up.
- **First-run order:**
  1. Apply this change (`home-manager switch`).
  2. Manually point `~/.config/colorschemes/.active` at `groovebox` (or wait for the `theme-switch` change to do it).
  3. `swaync-client --reload-css` (or restart swaync).
- **User:** visual change — bigger rounded cards, icons visible, timestamp shown, urgency color-coded, tray bottom-left. No new commands, no new dependencies.
- **Out of scope:** `theme-switch` script, picker, hook, gsettings flip, hyprland blur rules for the new swaync notification geometry (the existing blur rules in `modules/home-manager/hyprland/default.nix` still match the `swaync-notification-window` namespace and don't need to change).
