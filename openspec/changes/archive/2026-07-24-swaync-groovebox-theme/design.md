## Context

The user's setup is Hyprland on `jpporta-nixos` with swaync as the notification daemon. The current swaync configuration is split into two parts:

1. **`modules/home-manager/swaync/default.nix`** — the only place where swaync is configured. It inlines a ~400-line `style.css` string with hardcoded gruvbox colors (`#282828`, `#ebdbb2`, `#83a598`, `#fb4934`, `#504945`, `#fabd2f`) and a flat, square-ish layout. The settings block sets `positionX = "right"`, `positionY = "top"`, and a 360px-wide notification column with no corner radius beyond 14px.

2. **`modules/home-manager/hyprland/default.nix`** (lines 107–116) — already adds blur layers for `swaync-notification-window` and `swaync-control-center`, so the current design *intends* to be glassy but the CSS doesn't lean into it (no `alpha()`, low border-radius, no urgency-based color).

The user wants:

- A new "Groovebox" theme: dark, colorful, glassy.
- iOS-style notification cards: rounded, icon left, title + truncated body right, timestamp in small caps top-right, urgency-coded title color + border accent.
- Notification tray (the persistent control center) in the same dark glassy palette.
- Notifications pop from the **bottom-left** instead of top-right.
- A small `ponytail:` mindset: shipment is one new theme (`groovebox`) wired through the new layout, not 11 themes. Other themes get ported later.

The archived `2026-07-13-theme-switch` change designed the layout (`~/.config/colorschemes/<theme>/<app>/` + `.active` symlink + out-of-store symlinks from the Nix module) but was never implemented for swaync. This change ships the layout for swaync, with Groovebox as the first concrete theme so the user can see the result immediately.

Constraints:

- Nix home-manager on NixOS — the live reload path is `swaync-client --reload-css`, not a rebuild. The module must not bake colors.
- The active theme directory is expected to be reachable via `~/.config/colorschemes/.active` (a symlink set by the future `theme-switch` script). Since that script doesn't exist yet, this change places `groovebox` at `~/.config/colorschemes/groovebox/` and the Nix module points at `.active` — first-time setup also requires `ln -sfn ~/.config/colorschemes/groovebox ~/.config/colorschemes/.active` (documented in the change notes).
- The `~/.config/colorschemes/<theme>/` directory is currently empty. There is no `theme-switch` script yet. This change ships the dotfiles for one theme and expects the user (or a follow-up change) to wire `.active`.

## Goals / Non-Goals

**Goals:**

- iOS-style notification cards: large border-radius (16–20px), transparent dark background with alpha + blur, horizontal layout (icon left, summary + body right), small-caps timestamp in the top-right corner.
- Urgency-colored title and border: `low` = cyan, `normal` = white, `critical` = red. Applies in both the floating notification and the control center.
- Control center (notification tray) in the same glassy dark palette, larger border-radius (24px), transparent background, bottom-left position.
- Notifications pop from the bottom-left (`positionX = "left"`, `positionY = "bottom"`).
- Swaync config + stylesheet live in `~/.config/colorschemes/groovebox/swaync/` as dotfiles, not in the Nix store. The Nix module is a thin wrapper that `xdg.configFile`s out-of-store symlinks.
- `swaync-client --reload-css` continues to be the live-reload path; no rebuild required for tweaks.

**Non-Goals:**

- The `theme-switch` script itself, the `theme-picker`, the rofi integration, the boot-time `theme-apply.service`, the wallpaper hook. Those are the next change.
- Porting the existing 14 themes (`gruvbox-dark`, `catppuccin-mocha-dark`, etc.) into the new layout. Just `groovebox` ships here.
- gsettings / darkman integration changes.
- Hyprland blur rules: the existing `swaync-notification-window` + `swaync-control-center` blur rules already target the right namespaces; they continue to work.
- Changing the `font-family` ("BerkeleyMono Nerd Font Propo") or base font size — those stay.
- New external dependencies. No new packages.
- The CSS `all: unset` reset on `*` is kept from the current style (it works fine with swaync's GTK widgets and avoids inherited GTK theme leaks).

## Decisions

### D1. Two-file split: `style.css` (layout) + `colors.css` (palette)

The current Nix inline `style.css` and the thin `colors.css` from the theme-switch seeds get separate files. **Why:** colors are swapped per theme; layout is shared across all future themes. Other future themes can `cp groovebox/style.css` and just rewrite `colors.css`. **Alternative considered:** one file, with the colors inlined as CSS variables — fine, but the seeds archive already used a two-file split, so this stays consistent with the established convention.

### D2. Layout values live in `style.css`, palette lives in `colors.css`

`style.css` references palette via CSS custom properties: `--accent-critical`, `--accent-normal`, `--accent-low`, `--bg`, `--bg-alt`, `--text`, `--hover`, `--border`. `colors.css` defines them. **Why:** keeps the layout file theme-agnostic so other themes can reuse it. **Alternative:** put color literals in `style.css` — tied to one theme, defeats the point.

### D3. Out-of-store symlink for both files (the archived theme-switch pattern)

`xdg.configFile."swaync/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/colorschemes/.active/swaync/style.css";` and the same for `colors.css`. **Why:** the user's home dir is the source of truth. The Nix store never has the colors, so live edits + `swaync-client --reload-css` work without rebuild. **Alternative:** `text = builtins.readFile ...` — same effect for static configs, but breaks the moment the user edits the file: home-manager would silently overwrite on the next activation. The symlink is correct.

### D4. Active theme pointer is the user's responsibility (for this change)

The Nix module points at `~/.config/colorschemes/.active/swaync/`. If `.active` is missing, swaync ends up with a broken symlink and hyprland's swaync exec (`hl.exec_cmd("swaync")`) still starts the daemon, but the CSS fails to load. Two options considered:

- **Fallback: ship a default symlink in the Nix module** (`xdg.configFile."swaync/style.css".source = ... "${current}/style.css"` with `current = "groovebox"` if `.active` is missing). Cleaner first-run UX, but adds a Nix string that says "groovebox" — exactly the kind of hardcoding this change is trying to *remove*. **Rejected.**
- **Documented one-liner on first install.** First-run setup runs `mkdir -p ~/.config/colorschemes && ln -sfn ~/.config/colorschemes/groovebox ~/.config/colorschemes/.active && swaync-client --reload-css`. This is fine because it's a one-time setup, and the same command is what `theme-switch` will eventually own. **Chosen.**

The change notes in `tasks.md` will spell out the first-run command.

### D5. Urgency → color via class selectors, not via inline `style=`

Swaync adds CSS classes `.low`, `.normal`, `.critical` on the `.notification` element. The CSS reads:

```css
.notification.low .summary   { color: var(--accent-low); }
.notification.critical .summary { color: var(--accent-critical); }
.notification.critical .notification-background { border-color: var(--accent-critical); }
```

**Why:** swaync owns the class assignment; CSS owns the color. Theme swaps via `colors.css` alone. **Alternative considered:** inline `style` (e.g. `style="border-color: ..."`) — not supported by swaync's markup on the notification wrapper. Classes are the right path.

### D6. Timestamp displayed via the `.time` label, top-right

Swaync renders a `.time` label inside the notification header by default. The CSS positions it in the top-right corner of the notification card, small caps, dimmed (`color: alpha(var(--text), 0.55)`). **Why:** matches iOS, and the existing `widget-config.label.max-lines = 1` already constrains the body width so it doesn't compete with the timestamp.

### D7. Control center border-radius 24px; notification cards 16px

iOS uses a large radius on the full tray and a slightly smaller radius on individual cards. 16px gives a "tile" feel; 24px on the tray gives a "floating surface" feel. **Why:** matches iOS reference aesthetics. **Alternative:** uniform 16px — looks flat and grid-like, not iOS.

### D8. `transition-time` bumped to 250ms; `transition` CSS line kept

Swaync's `transition-time` setting controls the slide-in animation. iOS-style feels good at 200–300ms. We bump to 250ms. The existing CSS `transition: 200ms` inside `*` is a no-op (swaync uses transitions on actual property changes, not on `all`). We keep it for parity.

### D9. Notification close button + timestamp share the top-right corner

The current CSS puts the close button at the top-right. The new layout puts the close button to the **right of the timestamp** (still top-right, but the timestamp is the inner-most element). iOS shows the app icon on the trailing edge of the header; we use a close `×` button instead, since swaync doesn't auto-inject a close for floating notifications.

### D10. Color palette: invented Groovebox palette

| Token | Hex | Role |
|---|---|---|
| `--bg` | `#14171c` | deepest background |
| `--bg-alt` | `#1a1d24` | notification card / widget tile |
| `--bg-glass` | `rgba(20, 23, 28, 0.72)` | card body with alpha |
| `--text` | `#e6e6e6` | main foreground |
| `--text-dim` | `rgba(230, 230, 230, 0.55)` | timestamp, secondary |
| `--hover` | `#25282f` | hover highlight |
| `--accent-low` | `#5cd6ff` | low urgency (cool, calm) |
| `--accent-normal` | `#e6e6e6` | normal urgency (white-ish, matches iOS) |
| `--accent-critical` | `#ff5e7a` | critical urgency (loud red) |

**Why:** dark base, vibrant accents, follows the "colorful but dark" Groovebox vibe. The user can edit `colors.css` later to taste. **Alternative:** reuse gruvbox-dark's palette — defeats the point of a new theme.

## Risks / Trade-offs

- **First-run gotcha: `.active` symlink doesn't exist yet.** → Documented in `tasks.md` and in the change notes. The Nix module fails gracefully on `home-manager switch` (the symlink target just doesn't exist yet), so the user runs the one-liner manually. → **Mitigation:** the `theme-switch` change will own this; for now, one `ln -sfn` is acceptable.

- **CSS `all: unset` reset is aggressive and may break third-party widget styles.** Current code already has it; we keep it. Users who want fancier widget styling can override per-widget. → **Mitigation:** none needed (pre-existing behavior).

- **`transition-time = 250ms` may feel sluggish on slow hardware.** → **Mitigation:** documented as a tunable value in `colors.css` comments; the user can dial it back via `~/.config/swaync/config.json` (rebuilt by home-manager, but the change is small).

- **`background: alpha(...)` for the glass effect depends on the compositor passing blur through.** If hyprland's blur rules drift, the glass effect disappears. → **Mitigation:** the existing `swaync-notification-window` and `swaync-control-center` blur rules in `modules/home-manager/hyprland/default.nix` are untouched and still apply. If the user disables blur in hyprland, the card still has alpha + dark background, so it doesn't become invisible.

- **The `style.css` shell assumes class names `.low`, `.normal`, `.critical` survive swaync upgrades.** Swaync has used these classes for years; the API is stable. → **Mitigation:** if a future swaync release renames a class, the symptom is "urgency colors stop working" — visible immediately, fixable in one CSS line.

- **Out-of-store symlinks blow away if the user `rm -rf ~/.config/colorschemes/`.** → **Mitigation:** the `.active` symlink and theme dirs are dotfiles, versioned in `dotfiles/` (already the convention for swaync-alacritty-etc). A `git pull` in `~/dotfiles` restores them.

- **One theme shipped, not 14.** → **Mitigation:** the layout + colors split + symlink infra is now in place; porting the other themes is a follow-up cost (~10 minutes per theme: `cp -r groovebox/seeds/<theme>`, edit `colors.css`). Documented in the change notes as expected follow-up.

## Migration Plan

1. Apply the change: `home-manager switch --flake .#jpporta-nixos`.
2. First-run setup (one-time, also documented in `tasks.md`):
   ```sh
   mkdir -p ~/.config/colorschemes
   ln -sfn ~/.config/colorschemes/groovebox ~/.config/colorschemes/.active
   swaync-client --reload-css
   ```
3. Verify visually: trigger a test notification with `gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify swaync-test 0 '' Hello Groovebox "Test" '[]' '{}' 4000` and confirm the card appears bottom-left with the new look.
4. Rollback: revert to the previous Nix module (the old one had the inline `style.css`). The dotfiles in `~/.config/colorschemes/groovebox/` are tracked separately and don't affect rollback.

## Open Questions

- None blocking. The Groovebox palette is invented; the user can tweak `colors.css` after the first run.
- The `theme-switch` script is the natural follow-up change and will own `.active` symlink management from there.
