# GIF Recorder

## Purpose

This capability provides an opt-in Wayland workflow for recording a selected screen region as a GIF, saving it as a screenshot, and copying it to the clipboard.

## Requirements

### Requirement: Region recording is toggled by one command
The GIF recorder SHALL use one executable that starts an interactive region recording when idle and stops the active recording when invoked again.

#### Scenario: Start a recording
- **WHEN** the recorder is invoked while no recording is active
- **THEN** it lets the user select a rectangular Wayland region and starts recording that region

#### Scenario: Stop a recording
- **WHEN** the recorder is invoked while a recording is active
- **THEN** it stops the active recording and begins finalization without starting a second recording

#### Scenario: Cancel region selection
- **WHEN** the user cancels region selection before recording starts
- **THEN** the recorder exits without creating a GIF and clears its runtime state

### Requirement: Completed recordings are saved as GIF screenshots
The recorder SHALL save each successfully finalized recording as a timestamped `.gif` file below `~/Pictures/Screenshots`.

#### Scenario: Successful finalization
- **WHEN** an active recording is stopped and encoding succeeds
- **THEN** the recorder creates the screenshots directory if needed and stores one completed GIF there

#### Scenario: Failed finalization
- **WHEN** recording or GIF encoding fails
- **THEN** the recorder does not publish a partial GIF as a completed screenshot and removes temporary recording data

### Requirement: Completed recordings are copied to the Wayland clipboard
After successful GIF encoding, the recorder SHALL copy the resulting file to the Wayland clipboard using the `image/gif` MIME type.

#### Scenario: Clipboard copy succeeds
- **WHEN** a GIF is successfully written
- **THEN** the recorder publishes that GIF to the clipboard as `image/gif`

#### Scenario: Clipboard copy is unavailable
- **WHEN** a GIF is successfully written but clipboard publication fails
- **THEN** the recorder preserves the GIF in `~/Pictures/Screenshots` and exits without deleting it

### Requirement: Home Manager integration is opt-in
The feature SHALL be exposed as a Home Manager module with an enable option, and enabling it SHALL install all required runtime tools and the recorder executable.

#### Scenario: Module enabled
- **WHEN** `custom.gif-recorder.enable` is true
- **THEN** the user environment contains the recorder command and its Wayland recording, selection, encoding, and clipboard dependencies

#### Scenario: Module disabled
- **WHEN** `custom.gif-recorder.enable` is false
- **THEN** the module adds no GIF recorder command, packages, or Hyprland bind
