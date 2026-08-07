# Troubleshooting

## Confirm the session type

```sh
printf '%s\n' "${XDG_SESSION_TYPE:-unknown}"
```

An Xorg configuration has no effect when this prints `wayland`. Follow
[`wayland.md`](wayland.md) instead.

## Confirm the device and buttons

```sh
./scripts/inspect-device
sudo libinput debug-events --show-keycodes
```

If `047d:1002` is absent, use `lsusb` to find the ID of your hardware revision.
If the trackball appears in `lsusb` but not in libinput, inspect the kernel log
and udev properties before changing mappings.

## Avoid duplicate processing

Do not activate two remappers for the same device. A userspace remapper normally
grabs the physical device and creates a virtual one; compositor settings may then
need to target that virtual device. Test pointer motion, every button, wheel
scrolling, and hold-to-scroll after enabling a preset.

## Recovery

Keep a second pointing device or keyboard available while testing. If an input
remapper produces an unusable device, stop its service from a terminal or TTY.
For input-remapper this is normally:

```sh
sudo systemctl stop input-remapper
```

The X11 installer saves a replaced configuration beside the destination as
`90-kensington-trackball.conf.backup.YYYYMMDD-HHMMSS`. Restore that file with
`sudo install -m 644` if the generated layout is unsuitable.

## Report useful diagnostics

Include the compositor and version, distribution, `lsusb` ID, relevant block
from `libinput list-devices`, and button events from `libinput debug-events`.
Do not include unrelated input events that may reveal typed information.
