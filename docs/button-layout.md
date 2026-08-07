# Button layout

The numbers below are the physical/X button numbers used by the original
configuration. Confirm them on your own device before applying a preset: USB
revisions, the kernel, and remapping tools may report different identifiers.

| Physical button | Default project action |
| --- | --- |
| 1 | Primary click |
| 2 | Middle click (wheel press) |
| 3 | Legacy forward mapping and hold-to-scroll modifier |
| 4 | Wheel up |
| 5 | Wheel down |
| 8 | Back |
| 9 | Secondary click |
| 10–15 | F19–F24 |

The annotated device photograph is in
[`Kensington_Expert_Mouse_Pro.jpg`](../Kensington_Expert_Mouse_Pro.jpg).

The two button 3 actions are not simultaneous in libinput's native on-button
scrolling mode: libinput consumes press and release events for the configured
scroll button. Treat button 3 as the scroll modifier unless a separate remapper
implements and tests a tap-versus-hold action.

## Verify the hardware events

Run:

```sh
./scripts/inspect-device
sudo libinput debug-events --show-keycodes
```

Press and release each button once, recording the `BTN_*` or numeric event code.
Do this before configuring a Wayland compositor: Wayland configuration commonly
uses Linux event codes, not X11 button numbers.
