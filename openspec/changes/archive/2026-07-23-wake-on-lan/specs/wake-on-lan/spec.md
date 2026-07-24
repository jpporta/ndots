## ADDED Requirements

### Requirement: Persistent Wake-on-LAN on the wired NIC
The system SHALL keep the wired Ethernet interface (`enp14s0`) configured to wake on magic-packet while powered off.

#### Scenario: WOL applied on boot
- **WHEN** the system finishes booting
- **THEN** `ethtool enp14s0` SHALL report `Wake-on: g`

#### Scenario: WOL applied on resume from suspend
- **WHEN** the system resumes from suspend
- **THEN** `ethtool enp14s0` SHALL report `Wake-on: g`

### Requirement: Wake-on-LAN tooling available
The system SHALL provide `ethtool` and `wakeonlan` on `$PATH` so the user can inspect and trigger WOL.

#### Scenario: Inspect WOL state
- **WHEN** the user runs `ethtool enp14s0`
- **THEN** the command SHALL exit 0
- **AND** the output SHALL include `Supports Wake-on:` and `Wake-on:` lines

#### Scenario: Send a magic packet
- **WHEN** the user runs `wakeonlan <MAC>` (or `wake-jpporta-nixos`)
- **THEN** the command SHALL exit 0
- **AND** a UDP magic-packet SHALL be broadcast to `255.255.255.255:9`

### Requirement: Convenience wrapper to wake this host
The system SHALL provide a `wake-jpporta-nixos` command that sends a WOL magic packet to this machine's wired NIC MAC.

#### Scenario: Wake this machine from LAN
- **WHEN** the user runs `wake-jpporta-nixos`
- **THEN** the host's NIC SHALL receive the magic packet
- **AND** the system SHALL begin booting

#### Scenario: Wake this machine through a custom broadcast address
- **WHEN** the user runs `wake-jpporta-nixos 192.168.0.255`
- **THEN** the magic packet SHALL be sent to the `192.168.0.255` broadcast address
- **AND** the host SHALL begin booting

### Requirement: Reusable opt-in module
The system SHALL expose a `custom.wake-on-lan.enable` option that, when enabled, configures all of the above.

#### Scenario: Module disabled
- **WHEN** `custom.wake-on-lan.enable` is `false` or unset
- **THEN** the system SHALL NOT install the WOL systemd unit
- **AND** the system SHALL NOT install the `ethtool`, `wakeonlan`, or `wake-jpporta-nixos` packages

#### Scenario: Module enabled
- **WHEN** `custom.wake-on-lan.enable` is `true`
- **THEN** the WOL systemd unit SHALL be active
- **AND** the `wake-jpporta-nixos` command SHALL be on `$PATH`