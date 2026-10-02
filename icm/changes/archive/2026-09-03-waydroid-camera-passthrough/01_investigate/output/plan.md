# Plan — Waydroid camera passthrough (face detection use case)

Date: 2026-09-03
Status: approved

## Approval — plan
- **Approved by:** jpporta (conversation owner)
- **Granted:** "let's implement them, please make the backup first as I already logged in and other stuff in there I wouldn't want to loose."
- **Date:** 2026-09-03 16:35
- **Scope:** the full plan, with explicit instruction to back up Android userdata before `waydroid init -f`

## Target
- Host: `jpporta-nixos`, running Waydroid session (installed by change `2026-08-31-install-waydroid`).
- Scope: make the host webcam usable inside the Waydroid container so an Android app can run face detection on the live camera feed.
- Shared module impact: none expected — this change is runtime-only (see below); no repo configuration file needs to be edited.

## Requested behavior vs. current behavior
Requested: Android apps inside Waydroid can open the host camera (for face detection).

Current findings (verified on host):
- Waydroid 1.6.3 (`waydroid-nftables`) with **stock upstream images** (`ota.waydro.id`, GAPPS, MAINLINE vendor) is installed and running; `ro.hardware.camera=v4l2` is already set in `/var/lib/waydroid/waydroid_base.prop`.
- Waydroid already bind-mounts all `/dev/video*` nodes into the container automatically (`tools/helpers/lxc.py` globs `/dev/video*`), and the user is in the `video` group. Device-node plumbing is therefore already in place.
- **The camera HAL is the problem, not the mounts.** Per the official NixOS Wiki: "Camera forwarding using V4L2 is broken on upstream, but can be achieved by using the Waydroid images of the Waydroid-ATV project." The stock MAINLINE vendor image's v4l2 camera HAL does not expose devices to apps.
- Host devices: `/dev/video0` and `/dev/video2` are the real webcam (UVC pair), `/dev/video1` is a v4l2loopback virtual camera. **Note:** virtual cameras (v4l2loopback / akvcam, e.g. OBS output) are *not* detected by the Waydroid camera HAL — only real UVC devices work (documented in webcamoid/akvcam#96). Face detection must read the real webcam.
- Host GPU is AMD (`amdgpu`). Known follow-up issue (WayDroid-ATV/waydroid-builds#18): with ATV a16-qpr2 images on AMD GPUs, the camera app can crash the container (surfaceflinger YUV-texture abort) because `minigbm_gbm_mesa` mishandles YUV; the fix is an image build using `minigbm_amdgpu`, dropped into `/etc/waydroid-extra/images`.

## Desired behavior
1. Camera apps inside Waydroid enumerate and open the host UVC webcam (`/dev/video0`/`/dev/video2`).
2. A face-detection Android app receives a live preview stream.

## Proposed change
Runtime steps only (no repo file edits). If human review later requires persisting any of this (e.g., the `waydroid-helper`/extra-images approach in the module), that becomes a follow-up configuration change.

1. Stop the container: `sudo systemctl stop waydroid-container`.
2. Re-fetch images from the WayDroid-ATV project (a16-qpr2, GAPPS):
   ```
   sudo waydroid init -f \
     -c https://waydroid-atv.github.io/ota/a16-qpr2/system \
     -v https://waydroid-atv.github.io/ota/a16-qpr2/vendor \
     -r lineage \
     -s GAPPS
   ```
   ⚠️ Re-init risks wiping Android user data; back up `~/.local/share/waydroid` first if anything inside Android is worth keeping.
3. Start container and session: `sudo systemctl start waydroid-container && waydroid session start`.
4. If the setup wizard fails or the UI is unresponsive (documented ATV quirks):
   ```
   waydroid shell -- am start -a android.intent.action.MAIN -c android.intent.category.HOME
   waydroid shell -- pm disable-user --user 0 com.google.android.setupwizard
   waydroid shell -- pm disable-user --user 0 com.google.android.gms.setup
   ```
5. **Contingency (AMD GPU crash):** if opening the camera crashes/reboots the container, download the `minigbm_amdgpu` build referenced in WayDroid-ATV/waydroid-builds#18 and extract it to `/etc/waydroid-extra/images`, then re-run `waydroid init -f`.

## Validation
- `waydroid shell -- dumpsys media.camera | head -20` reports ≥1 camera device (device id `100`, facing front).
- Open a camera app (or the face-detection app) in Waydroid: webcam in-use LED lights up and preview shows.
- Confirm the host camera still works for native apps after the change (Waydroid releases the node on session stop).

## Deployment
`sudo` shell commands above, executed by the user after this plan is approved. Nothing is rebuilt (`nixos-rebuild` not needed — no config change).

## Risks and rollback
- Risk: **Android data loss** on `waydroid init -f` (apps, Play Store login, app data). Mitigation: explicit backup step; GAPPS device registration (Android ID) may need to be redone.
- Risk: ATV images are a third-party (community) build of LineageOS, not the official OTA channel; trust and update cadence differ. GAPPS certification may need re-registration.
- Risk: AMD-specific camera crash (known issue) — contingency in step 5; worst case the camera remains unusable inside Waydroid while everything else keeps working.
- Rollback: stop the container and re-init from the official channel:
  `sudo waydroid init -f -s GAPPS` (uses `ota.waydro.id` again), restoring the previous environment; or fully reset via the documented wipe procedure.

## Human gate
Approve this plan (especially the data-wipe implication of step 2) before any runtime command is executed.
