# Spec: swaync-groovebox-theme

## ADDED Requirements

### Requirement: Swaync module sources its stylesheet from the active colorscheme dir

The swaync Home Manager module SHALL NOT inline CSS strings. Instead, the module SHALL ensure that `~/.config/swaync/style.css` and `~/.config/swaync/colors.css` are sourced from the active theme dir via out-of-store symlinks to `~/.config/colorschemes/.active/swaync/`.

#### Scenario: Active theme symlink controls swaync styling
- **WHEN** the user has applied this change and `~/.config/colorschemes/.active` points at `groovebox`
- **THEN** `~/.config/swaync/style.css` resolves through `~/.config/colorschemes/.active/swaync/style.css`
- **AND** `~/.config/swaync/colors.css` resolves through `~/.config/colorschemes/.active/swaync/colors.css`
- **AND** the swaync Nix module contains no color hex strings or CSS rules

#### Scenario: Without an active theme symlink, swaync still starts
- **WHEN** the user has applied this change but `~/.config/colorschemes/.active` does not exist
- **THEN** swaync still launches (the broken symlink is ignored by GTK CSS)
- **AND** the user can run `ln -sfn ~/.config/colorschemes/groovebox ~/.config/colorschemes/.active && swaync-client --reload-css` to restore styling (documented in the change notes)

### Requirement: Groovebox theme ships a Swaync stylesheet with iOS-style layout

The `groovebox` colorscheme SHALL include a `swaync/style.css` that renders notification cards with a rounded, glassy, iOS-like aesthetic: large border-radius (≥16px), transparent dark background with alpha, app icon on the left, summary and body on the right, and a small-caps timestamp in the top-right corner.

#### Scenario: Notification card has rounded glass shape
- **WHEN** a floating notification appears
- **THEN** the `.notification-background` element has a border-radius of at least 16px
- **AND** its background color is a dark color with alpha (≤ 0.85) so the underlying compositor blur can show through
- **AND** its border is at least 1px wide

#### Scenario: Notification card uses horizontal layout
- **WHEN** a floating notification appears
- **THEN** the app icon, summary, and body are arranged horizontally (icon left, text right)
- **AND** the summary line is truncated to a single line if it overflows
- **AND** the body line is truncated if it overflows

#### Scenario: Timestamp appears in the top-right of the notification card
- **WHEN** a floating notification appears
- **THEN** a `.time` element is visible in the top-right corner of the card
- **AND** it is rendered in small caps
- **AND** its color is dimmer than the summary text

### Requirement: Notification urgency drives title color and border color

The Groovebox swaync stylesheet SHALL color the notification summary text and the notification border according to the urgency level: `low` = cyan, `normal` = off-white, `critical` = red. The colors SHALL be defined via CSS custom properties in `colors.css` so a future theme override is a one-line change.

#### Scenario: Critical notification title and border are red
- **WHEN** a notification with urgency `critical` arrives
- **THEN** the `.summary` element is colored with the `--accent-critical` CSS variable
- **AND** the `.notification-background` border is colored with the `--accent-critical` CSS variable

#### Scenario: Low-urgency notification title and border are cyan
- **WHEN** a notification with urgency `low` arrives
- **THEN** the `.summary` element is colored with the `--accent-low` CSS variable
- **AND** the `.notification-background` border is colored with the `--accent-low` CSS variable

#### Scenario: Normal-urgency notification uses the default text color
- **WHEN** a notification with urgency `normal` arrives
- **THEN** the `.summary` element is colored with the `--accent-normal` CSS variable
- **AND** the `.notification-background` border is colored with the `--accent-normal` CSS variable

### Requirement: Notifications pop from the bottom-left

The swaync Nix module SHALL set `positionX = "left"` and `positionY = "bottom"` so notifications appear in the bottom-left corner of the screen.

#### Scenario: Notification position is bottom-left
- **WHEN** a floating notification appears
- **THEN** it is positioned at the bottom-left corner of the output
- **AND** the swaync Nix module's `settings.positionX` is `"left"` and `settings.positionY` is `"bottom"`

### Requirement: Control center (notification tray) uses the dark glassy palette

The Groovebox swaync stylesheet SHALL render the control center with the same dark, glassy palette as the notification cards: dark background with alpha, large border-radius (≥24px), and a visible border.

#### Scenario: Control center is dark and glassy
- **WHEN** the user opens the notification tray via `swaync-client -t`
- **THEN** the control center has a background color matching `--bg-glass` (or `--bg` with alpha)
- **AND** its border-radius is at least 24px
- **AND** its border is at least 1px wide and uses the `--accent-normal` color

### Requirement: Groovebox theme ships a colors.css with the palette

The `groovebox` colorscheme SHALL include a `swaync/colors.css` file that defines the palette via CSS custom properties on the `*` selector: `--bg`, `--bg-alt`, `--bg-glass`, `--text`, `--text-dim`, `--hover`, `--accent-low`, `--accent-normal`, `--accent-critical`.

#### Scenario: Groovebox palette is defined
- **WHEN** the user inspects `~/.config/colorschemes/groovebox/swaync/colors.css`
- **THEN** it contains at least the nine CSS custom properties listed above
- **AND** the colors form a dark, colorful palette (base colors are dark, accents are vibrant)

### Requirement: Groovebox theme ships a meta file with name and mode

The `groovebox` colorscheme SHALL include a `meta` file at `~/.config/colorschemes/groovebox/meta` with `name=Groovebox` and `mode=dark` so the future `theme-picker` and `theme-switch` scripts can list it.

#### Scenario: Groovebox meta file is present
- **WHEN** the user reads `~/.config/colorschemes/groovebox/meta`
- **THEN** it contains a line `name=Groovebox`
- **AND** it contains a line `mode=dark`
- **AND** the file is plain text with one KEY=value per line
