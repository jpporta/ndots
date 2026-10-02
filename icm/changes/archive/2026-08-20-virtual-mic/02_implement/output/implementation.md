# Implementation: virtual microphone input

## Approved change

Fixed the existing `virtual-mic` Home Manager utility after live testing showed that the null sink monitor was not exposed as a proper virtual input device.

## Changed path

- `modules/home-manager/audio-rate/default.nix`

## Behavior

- `virtual-mic start` creates the `virtual_mic` null sink and loops the current default output monitor into it.
- It creates a named `virtual_mic_source` with the description `Virtual_Microphone`, backed by `virtual_mic.monitor` through `module-remap-source`.
- `virtual-mic stop` removes the remapped source, loopback, and null sink in dependency order.
- `status` requires both the sink and virtual source to exist.
- `toggle` uses the sink state to start or stop the setup.

The existing `audio-rate` module provides the command to `jpporta-nixos`; the writer-deck remains unaffected.

## Intentional deviation

The original plan relied on applications selecting the null sink monitor directly. The implementation now also exposes a named source so applications can select `Virtual_Microphone` as a normal input device.
