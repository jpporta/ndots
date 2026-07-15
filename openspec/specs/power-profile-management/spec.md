# Power Profile Management

## Purpose

This capability provides configurable power management profiles that control system behavior such as screen blanking, locking, and suspension.

## ADDED Requirements

### Requirement: Manage Power Profiles
The system SHALL provide three distinct power management profiles: `caffeinated`, `headless`, and `normal`.

#### Scenario: Caffeinated Profile
- **WHEN** the `caffeinated` profile is active
- **THEN** the system SHALL NOT blank the screen.
- **AND** the system SHALL NOT lock the screen.
- **AND** the system SHALL NOT suspend.

#### Scenario: Headless Profile
- **WHEN** the `headless` profile is active
- **THEN** the system SHALL blank the screen after a timeout.
- **AND** the system SHALL lock the screen when it blanks.
- **AND** the system SHALL NOT suspend.

#### Scenario: Normal Profile
- **WHEN** the `normal` profile is active
- **THEN** the system SHALL blank the screen after a default timeout.
- **AND** the system SHALL lock the screen when it blanks.
- **AND** the system SHALL suspend after a longer default timeout.

### Requirement: Cycle Through Power Profiles
The system SHALL allow the user to cycle through the power profiles using a keybinding.

#### Scenario: Cycle Forward
- **WHEN** the user presses the "next profile" keybinding
- **THEN** the active power profile SHALL change from `normal` to `caffeinated`, `caffeinated` to `headless`, and `headless` to `normal`.

#### Scenario: Cycle Backward
- **WHEN** the user presses the "previous profile" keybinding
- **THEN** the active power profile SHALL change from `normal` to `headless`, `headless` to `caffeinated`, and `caffeinated` to `normal`.

### Requirement: Visual Indicator for Current Profile
The system SHALL display the current power profile mode in the Waybar status bar.

#### Scenario: Display Caffeinated Icon
- **WHEN** the `caffeinated` profile is active
- **THEN** a "caffeinated" icon SHALL be visible in the Waybar status bar.

#### Scenario: Display Headless Icon
- **WHEN** the `headless` profile is active
- **THEN** a "headless" icon SHALL be visible in the Waybar status bar.

#### Scenario: Display Normal Icon
- **WHEN** the `normal` profile is active
- **THEN** a "normal" icon SHALL be visible in the Waybar status bar.
