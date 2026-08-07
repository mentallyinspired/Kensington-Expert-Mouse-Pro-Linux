# Nix flake and Home Manager

The flake exports a package containing the project tools and documentation, plus
a Home Manager module for GNOME, Hyprland, niri, and Sway. KDE Plasma is not in
the module because KWin's input object must be discovered at runtime; use the
Plasma procedure in [`wayland.md`](wayland.md#kde-plasma).

## Add the flake

Add this repository and make its nixpkgs input follow your system nixpkgs:

```nix
inputs.kensington = {
  url = "github:mentallyinspired/Kensington-Expert-Mouse-Pro-Linux/wayland-support";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import the module in the relevant Home Manager configuration:

```nix
imports = [ inputs.kensington.homeManagerModules.default ];
```

The branch URL is appropriate while this work is under review. Change it to the
final tag or main branch after the work is merged.

## Configure a compositor

Only enable one compositor value per Home Manager profile. First determine the
real button code and, for Sway or Hyprland, exact device name.

### Sway

```nix
programs.kensington-expert-mouse-pro = {
  enable = true;
  compositor = "sway";
  device = "<identifier-from-swaymsg-get_inputs>";
  scrollButton = 274;
};
```

### Hyprland

```nix
programs.kensington-expert-mouse-pro = {
  enable = true;
  compositor = "hyprland";
  device = "<name-from-hyprctl-devices>";
  scrollButton = 274;
};
```

The module follows Home Manager's `hyprland.configType`, generating Lua for
Hyprland 0.55+ or hyprlang for older configurations.

### GNOME

GNOME uses a logical button number rather than a Linux event code:

```nix
programs.kensington-expert-mouse-pro = {
  enable = true;
  compositor = "gnome";
  scrollButton = 3;
};
```

### niri

```nix
programs.kensington-expert-mouse-pro = {
  enable = true;
  compositor = "niri";
  scrollButton = 274;
};
```

This generates `~/.config/niri/kensington-trackball.kdl`. Add the fragment to
the `input` block in the main niri configuration:

```kdl
input {
    include "kensington-trackball.kdl"
}
```

niri currently applies the trackball block to every trackball.

## Optional tools

The module installs input-remapper, libinput tools, usbutils, and `wev` by
default. Set `installTools = false` to manage them elsewhere. Installing the
input-remapper package does not automatically enable its privileged service;
follow the distribution/NixOS service setup appropriate to the pinned nixpkgs.

## Build and check

```sh
nix flake show
nix flake check
nix build
```
