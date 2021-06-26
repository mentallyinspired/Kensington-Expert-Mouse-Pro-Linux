# Kensington Expert Mouse Pro Linux conf

This guide (and config) will give you a fully working Kensington Expert Mouse Pro under Linux.

<img src="https://github.com/s00nice/Kensington-Expert-Mouse-Pro-Linux/blob/main/Kensington_Expert_Mouse_Pro.jpg" width="400">

**With the following settings**

* Key nr 1 for normal keypress
* Key nr 3 for forward
* Key nr 3 (while held down) for scrolling with trackball
* Key nr 8 for back
* Key nr 9 for right click
* Key nr 10-15 (buttons numbered 1-6) mapped to F19-F24
* Scroll is left as is (key 4 and 5)
* Key nr 2 (pressing the scroll wheel) for middle mouse click
* 4 and 5 are left as is and are for scrolling with the scroll wheel

## Base config

Download the `kensington-trackball.conf` file and place it in `/etc/X11/xorg.conf.d/`

If the conf doesn't work after restarting x then you need to modify `MatchProduct` or replace it with `MatchUSBID`.

### Get `MatchProduct` name

Install `xorg-xinput` if not already installed, then run:

```bash
$ xinput list
```

Which gives:

```bash
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Kensington Kensington USB/PS2 Trackball   id=14   [slave  pointer  (2)]
```

The device name should be under `Virtual core pointer` in the output.
Replace the name in the conf file with the output name

Like so:

```bash
  MatchProduct "Kensington Kensington USB/PS2 Trackball"
  # use the output name from 'xinput list'
```

### Replace `MatchProduct` with `MatchUSBID` (optional)

First get the USBID of the trackball.

```bash
$ lsusb
```

Which gives:

```bash
Bus 003 Device 005: ID 047d:1002 Kensington Expert Mouse Pro
```

Then replace in the conf file
```bash
  MatchProduct "Kensington Kensington USB/PS2 Trackball"
```

with

```bash
  MatchUSBID "047d:1002"
  # use your actual USBID, could be the same as this
```

### Settings for left handed

If you are left handed and want to mirror the settings of the four keys around the trackball then replace `ButtonMapping` and `ScrollButton` with:

```conf
  Option "ScrollButton" "1"
  Option "ButtonMapping" "3 2 8 4 5 6 7 9 1 10 11 12 13 14 15"
```

## Map the top 1-6 buttons to F19-F24 (optional)

Here we will map the blue top buttons (numbered 1-6) to F19 trough F24 which will allow us to make use of them like any other keyboard button. This is useful when assigning keyboard shortcuts.

### Install dependencies

* xorg-xmodmap
* xautomation
* xbindkeys

### Check for unused keycodes

Check with

```bash
$ xmodmap -pke
```

Note down six unused keycodes, these will be used for mapping F19-F24.

### Create new keycode bindings for F19-F24

Create and edit file for new keycode assignments

```bash
$ nano ~/.Xmodmap
```

Bind F19-F24 keys to unused keycodes, bellow keycodes ware empty for me which I assigned to F19-F24.

```conf
keycode 247 = F19
keycode 248 = F20
keycode 249 = F21
keycode 250 = F22
keycode 252 = F23
keycode 253 = F24
```

Then update xmodmap:

```bash
$ xmodmap ~/.Xmodmap
```

Create a new file for mapping F19-F24 to the blue (1-6) buttons on the trackball
```bash
$ nano ~/.xbindkeysrc
```

Map the blue (1-6) keys to F19-F24

```conf
"xte 'key F19'"
b:10

"xte 'key F20'"
b:11

"xte 'key F21'"
b:12

"xte 'key F22'"
b:13

"xte 'key F23'"
b:14

"xte 'key F24'"
b:15

```

Edit `.xinitrc` to autostart `xbindkeys`

```bash
$ nano ~/.xinitrc
```
add `xbindkeys` BEFORE the line that starts your window manager or DE. This is to ensure that the conf in `~/.xbindkeysrc` gets activated before your window manager starts.

```conf
xbindkeys
DEFAULT_SESSION=yourWindowManager
```

## Check functionality of the 1-6 keys

Run

```bash
$ xbindkeys --key
```
Press one of the six buttons within the rectangular area.
You should get something like this:

```bash
"(Scheme function)"
    m:0x0 + c:247
    F19
```
Which is for button 1 that is mapped to F19 on keycode 247.

Congratulation, you should now have a fully functional Kensington Expert Mouse Pro under Linux.
