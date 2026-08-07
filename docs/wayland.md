# Wayland setup

Wayland compositors consume libinput directly. There is no universal equivalent
of `/etc/X11/xorg.conf.d`, so hold-to-scroll must be configured in the active
compositor. Button-to-key conversion is handled separately with a uinput-based
remapper; see [`remapping.md`](remapping.md).

First record the trackball name and physical button codes:

```sh
./scripts/inspect-device
sudo libinput debug-events --show-keycodes
```

The button values below are examples. Use the event emitted by the physical
button you want to hold while rolling the ball.

## Sway

Get the exact device identifier:

```sh
swaymsg -t get_inputs
```

Add this to `~/.config/sway/config`, substituting the identifier and button:

```conf
input "<identifier>" {
    scroll_method on_button_down
    scroll_button BTN_MIDDLE
    scroll_button_lock disabled
}
```

Reload the Sway configuration. Sway accepts a Linux event name or number for
`scroll_button`; an event name is less ambiguous than an X11 button number.

Reference: [`sway-input(5)`](https://man.archlinux.org/man/sway-input.5.en).

## Hyprland

Get the exact pointer name and the running Hyprland version:

```sh
hyprctl devices
hyprctl version
```

Hyprland expects `scroll_button` to be a numeric Linux event code. Confirm it
with `libinput debug-events` or `wev`; 274 (`BTN_MIDDLE`) below is only an
example.

### Hyprland 0.55 and newer

Hyprland 0.55 moved configuration to Lua. Add a per-device entry to the active
Hyprland Lua configuration, replacing the name and button code:

```lua
hl.device({
    name = "<name-from-hyprctl-devices>",
    scroll_method = "on_button_down",
    scroll_button = 274,
    scroll_button_lock = false,
})
```

Using `hl.device()` limits the setting to the Kensington instead of changing
every pointer. Reload the configuration and check for errors:

```sh
hyprctl reload
hyprctl configerrors
```

### Hyprland 0.54 and older

For a release still using `~/.config/hypr/hyprland.conf`, add:

```conf
device {
    name = <name-from-hyprctl-devices>
    scroll_method = on_button_down
    scroll_button = 274
    scroll_button_lock = false
}
```

Do not quote or alter the device name reported by `hyprctl devices` in the old
syntax. Hyprland reloads `hyprland.conf` when it changes; `hyprctl reload` can
also reload it explicitly.

References: [current Hyprland device configuration](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/),
[current input variables](https://wiki.hypr.land/Configuring/Basics/Variables/),
and [Hyprland 0.54 configuration](https://wiki.hypr.land/0.54.0/Configuring/Keywords/#per-device-input-configs).

## niri

Add a trackball block to `~/.config/niri/config.kdl`:

```kdl
input {
    trackball {
        scroll-method "on-button-down"
        scroll-button 274 // Example only: replace with the observed event code.
        // scroll-button-lock
    }
}
```

niri reloads the configuration when it changes. `scroll-button` is available
since niri 0.1.10 and `scroll-button-lock` since niri 25.08. Leave the lock line
commented for hold-to-scroll behavior.

Important: niri currently applies this block to every trackball and does not
provide per-device matching. This is safe when the Kensington is your only
trackball; otherwise all attached trackballs receive the same setting.

References: [niri input configuration](https://niri-wm.github.io/niri/Configuration%3A-Input.html)
and [niri key bindings](https://niri-wm.github.io/niri/Configuration%3A-Key-Bindings.html).

## GNOME

GNOME exposes the libinput trackball scroll-button setting through GSettings.
First confirm that the schema keys exist and that udev classifies the event node
as a trackball:

```sh
gsettings list-keys org.gnome.desktop.peripherals.trackball
udevadm info --query=property --name=/dev/input/eventN | rg '^ID_INPUT_TRACKBALL='
```

Replace `eventN` with the device node reported by libinput. Mutter only applies
these settings to devices with `ID_INPUT_TRACKBALL=1`.

Read the current values before changing them:

```sh
gsettings get org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button
gsettings get org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button-lock
```

Set it to the numeric button discovered during inspection:

```sh
gsettings set org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button 3
gsettings set org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button-lock false
```

GNOME expects a logical button number from 0 through 24 here, not a Linux event
code such as 274. Zero disables the feature. The setting is persistent and
applies live to GNOME's entire trackball device class rather than an Xorg
`MatchProduct` rule. Confirm behavior after applying it and reset both keys if
the chosen number does not refer to the intended physical button:

```sh
gsettings reset org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button
gsettings reset org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button-lock
```

## KDE Plasma

KWin owns libinput configuration in a Plasma Wayland session. Plasma's public
Mouse settings do not currently document button scrolling, but Plasma 6 exposes
the required per-device properties over D-Bus and persists successful changes.
Treat this as an advanced, version-sensitive procedure until it is tested on
your Plasma release.

List the dynamic input-device objects; use `qdbus` instead of `qdbus6` on a
distribution that provides the older command name:

```sh
qdbus6 org.kde.KWin | rg '^/org/kde/KWin/InputDevice/'
```

For each candidate path, inspect its name and support flag. Quote the selected
path in every command:

```sh
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.name
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.supportsScrollOnButtonDown
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.scrollButton
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.scrollOnButtonDown
```

Record the original values. If support is `true`, set the verified Linux event
code and enable the method. Here 274 (`BTN_MIDDLE`) is only an example:

```sh
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.scrollButton 274
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.scrollOnButtonDown true
```

To disable on-button scrolling again:

```sh
qdbus6 org.kde.KWin "$path" org.kde.KWin.InputDevice.scrollOnButtonDown false
```

Never save an `eventN` object path in a script: event numbers can change after
reboot or reconnect. Current implementation reference:
[KWin libinput device interface](https://github.com/KDE/kwin/blob/master/src/backends/libinput/device.h).

## Verify

For every compositor:

1. Confirm ordinary pointer motion and wheel scrolling.
2. Hold the selected button and roll vertically and horizontally.
3. Confirm that a short click of the scroll modifier does not cause an unwanted
   action. Libinput consumes that button while on-button scrolling is active.
4. Test all extra-button mappings in a native Wayland application.
5. Reconnect the USB device and log in again to verify persistence.

Libinput documents the underlying behavior in
[On-Button scrolling](https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html#on-button-scrolling).
