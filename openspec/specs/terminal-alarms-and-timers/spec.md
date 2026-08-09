## Purpose

Provide terminal timers and wall-clock alarms that persist independently of the creating shell, notify on completion, and expose the nearest active events in Waybar.

## Requirements

### Requirement: Create timers

The system SHALL provide a `timer` command that accepts a positive duration and creates a new timer with a unique numeric ID and an absolute local wall-clock deadline.

#### Scenario: Create a minute timer

- **WHEN** the user runs `timer 10m`
- **THEN** the system creates one timer due ten minutes after the command is accepted and prints its numeric ID

#### Scenario: Reject an invalid duration

- **WHEN** the user runs `timer 0m`, `timer -1h`, or an unsupported duration format
- **THEN** the system rejects the command without creating an event

### Requirement: Create alarms

The system SHALL provide an `alarm` command that accepts a local time, an optional date, and an optional free-form description.

#### Scenario: Create a future time-only alarm

- **WHEN** the user runs `alarm 15:10` before 15:10 local time
- **THEN** the system creates an alarm for 15:10 on the current local date

#### Scenario: Roll a passed time-only alarm to tomorrow

- **WHEN** the user runs `alarm 15:10` at or after 15:10 local time
- **THEN** the system creates an alarm for 15:10 on the next local date

#### Scenario: Create a dated alarm with a description

- **WHEN** the user runs `alarm 2026-08-01 10:20 Important Meeting`
- **THEN** the system creates an alarm for that local date and time with `Important Meeting` as its description

#### Scenario: Reject a past explicit date

- **WHEN** the user supplies an explicit date and the resulting local timestamp is in the past
- **THEN** the system rejects the command without creating an event

#### Scenario: Reject a duplicate alarm timestamp

- **WHEN** an alarm already exists at the requested normalized timestamp
- **THEN** the system rejects the new alarm without creating a second event

### Requirement: List active events

The system SHALL provide `timer list` and `alarm list` commands that display active events with their numeric IDs, type-appropriate due information, and optional descriptions.

#### Scenario: List timers and alarms

- **WHEN** the user runs either list command
- **THEN** the system displays only active events of that type in deadline order with IDs suitable for cancellation

#### Scenario: List with no events

- **WHEN** the selected event type has no active events
- **THEN** the system exits successfully and reports that no events are scheduled

### Requirement: Cancel events by ID

The system SHALL provide `timer cancel ID` and `alarm cancel ID` commands that remove the matching active event.

#### Scenario: Cancel an existing event

- **WHEN** the user cancels an existing event ID with the matching command
- **THEN** the system removes that event and confirms the cancellation

#### Scenario: Cancel an unknown or mismatched ID

- **WHEN** the requested ID does not exist for the selected command
- **THEN** the system reports an error and leaves all events unchanged

### Requirement: Persist and serialize event state

The system SHALL persist active events under the user's XDG state directory and SHALL serialize state mutations so concurrent creation, cancellation, scheduling, and firing cannot overwrite each other's changes.

#### Scenario: Terminal exits after creation

- **WHEN** the shell that created an event exits
- **THEN** the event remains available to the scheduler and list commands

#### Scenario: Concurrent state mutation

- **WHEN** a command and the scheduler update state at the same time
- **THEN** one complete update is applied without corrupting or losing unrelated events

### Requirement: Schedule due events

The system SHALL run a user-level scheduler that checks active events against the local wall clock and completes each observed due event once.

#### Scenario: Timer reaches its deadline

- **WHEN** the scheduler observes an active timer at or after its deadline before it has been missed
- **THEN** the system removes the timer and emits its completion effects exactly once

#### Scenario: Event is missed while unavailable

- **WHEN** an event deadline passes while the computer or scheduler is unavailable
- **THEN** the system removes the event without emitting a notification or sound

#### Scenario: Completion effect fails

- **WHEN** notification or sound playback fails after an event is marked complete
- **THEN** the event remains removed and is not retried as a duplicate event

### Requirement: Notify and play sound on completion

The system SHALL send one critical desktop notification and SHALL attempt to play a one-second PipeWire sound when an observed timer or alarm completes.

#### Scenario: Complete an event with a description

- **WHEN** an event with a description completes
- **THEN** the critical notification identifies the event type and includes the description, and the system attempts one sound playback

#### Scenario: Complete an event without a description

- **WHEN** an event without a description completes
- **THEN** the critical notification identifies the event type and deadline without an empty description artifact, and the system attempts one sound playback

### Requirement: Display the nearest events in Waybar

The system SHALL provide a JSON-producing Waybar helper that refreshes every second and represents at most the three closest active events across timers and alarms.

#### Scenario: Display mixed event types

- **WHEN** active timers and alarms exist
- **THEN** the helper sorts all events by deadline and emits only the three closest with distinct timer and alarm icons

#### Scenario: Format a timer above one minute

- **WHEN** a displayed timer has at least one minute remaining
- **THEN** its text uses `HH:MM` remaining time

#### Scenario: Format a timer below one minute

- **WHEN** a displayed timer has less than one minute remaining
- **THEN** its text contains only the remaining seconds

#### Scenario: Format an alarm

- **WHEN** a displayed alarm is active
- **THEN** its text contains its fixed local due time in `HH:MM` format

#### Scenario: Hide the empty module

- **WHEN** no active events exist
- **THEN** the helper emits an empty Waybar text value

#### Scenario: Show descriptions safely

- **WHEN** a displayed event has a description containing spaces or JSON-sensitive characters
- **THEN** the helper emits valid JSON and exposes the description through the tooltip without shell or JSON injection

### Requirement: Integrate the Waybar module

The Waybar configuration SHALL place the event module immediately after workspaces in `modules-left`, refresh it every second, use JSON return type, and define no click actions.

#### Scenario: Load the module in the left bar

- **WHEN** Waybar starts with the updated external configuration
- **THEN** the event module appears after the workspace module and disappears when its text is empty
