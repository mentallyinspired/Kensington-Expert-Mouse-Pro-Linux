# Remapping the extra buttons

The six blue buttons can be exposed as F19–F24 with a userspace remapper that
reads evdev and creates a virtual uinput device. This works for native Wayland
applications as well as X11.

[`input-remapper`](https://github.com/sezanzeb/input-remapper) is the recommended
interactive option because it supports mice, keyboard keys, Wayland, X11, and
preset autoloading.

## Create the preset

1. Install input-remapper 2.x from your distribution.
2. Start `input-remapper-gtk`.
3. Select the Kensington device.
4. Create a preset named `f19-f24`.
5. Record each blue button and map them, in physical order, to F19 through F24.
6. Apply the preset, test it, and enable autoload only after pointer motion and
   every ordinary button still work.

Presets identify device capabilities as well as event codes. For that reason,
the repository does not ship an untested hand-written JSON preset that could
grab the wrong device or disable pointer events on another hardware revision.
The X11 button numbers 10–15 are not necessarily the raw evdev codes a version
2 preset requires.

## Service and command-line checks

Package integration differs by distribution. On systemd distributions, inspect
the service without assuming it is already running:

```sh
systemctl status input-remapper
input-remapper-control --command hello
sudo input-remapper-control --list-devices
input-remapper-control --symbol-names | rg '^KEY_F(19|2[0-4])$'
```

Load all presets configured for autoload with:

```sh
input-remapper-control --command autoload
```

Upstream usage reference:
[input-remapper usage](https://github.com/sezanzeb/input-remapper/blob/main/readme/usage.md).

## Interaction with hold-to-scroll

A remapper may grab the physical device and publish a virtual replacement. If
the compositor's scroll setting stops applying, inspect the virtual device and
target it in the compositor configuration. Never run multiple grabbing
remappers for the same trackball.

F19–F24 must be tested in a native Wayland application. Success in an Xwayland
terminal alone does not prove that the mapping is session-wide. `wev` is useful
on compositors that support the input-method protocol; otherwise bind each key
temporarily to a harmless compositor action.
