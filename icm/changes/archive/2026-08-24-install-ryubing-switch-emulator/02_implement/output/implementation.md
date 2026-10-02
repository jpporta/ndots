# Implementation — Install Ryubing (Nicholas Switch Emulator)

## Change applied
- In `modules/home-manager/arch-packages/default.nix`:
  Added `ryubing` to the `# ---- GUI apps ----` section of `home.packages` with the comment `# Ryujinx switch emulator (community fork)`.

```nix
      # ---- GUI apps ----
      ryubing # Ryujinx switch emulator (community fork)
      obsidian
      ...
```

## Scope
Only `modules/home-manager/arch-packages/default.nix` was modified, for the `jpporta-nixos` host.

## Human check
Review the diff before validation.