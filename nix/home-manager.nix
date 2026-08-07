{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.programs.kensington-expert-mouse-pro;
  button = toString cfg.scrollButton;
  device = if cfg.device == null then "" else cfg.device;
  lockSway = if cfg.scrollButtonLock then "enabled" else "disabled";
  lockHypr = if cfg.scrollButtonLock then "true" else "false";
in
{
  options.programs.kensington-expert-mouse-pro = {
    enable = mkEnableOption "Kensington Expert Mouse Pro Wayland configuration";

    compositor = mkOption {
      type = types.enum [
        "gnome"
        "hyprland"
        "niri"
        "sway"
      ];
      description = "Wayland compositor or desktop to configure.";
    };

    device = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Exact compositor device name. Obtain it with `swaymsg -t get_inputs`
        for Sway or `hyprctl devices` for Hyprland. GNOME and niri currently
        apply trackball settings by device class, so this value is ignored.
      '';
    };

    scrollButton = mkOption {
      type = types.ints.between 0 65535;
      default = 274;
      description = ''
        Scroll-modifier button. Sway, Hyprland, and niri expect a Linux event
        code such as 274 for BTN_MIDDLE. GNOME expects a logical button number,
        commonly 3. Confirm the value on the physical device.
      '';
    };

    scrollButtonLock = mkOption {
      type = types.bool;
      default = false;
      description = "Toggle scrolling instead of requiring the button to be held.";
    };

    installTools = mkOption {
      type = types.bool;
      default = true;
      description = "Install libinput tools, usbutils, wev, and input-remapper.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion =
            !(builtins.elem cfg.compositor [
              "hyprland"
              "sway"
            ])
            || cfg.device != null;
          message = "Kensington setup requires `device` for Sway and Hyprland.";
        }
      ];
      home.packages = lib.optionals cfg.installTools [
        pkgs.input-remapper
        pkgs.libinput
        pkgs.usbutils
        pkgs.wev
      ];
    }

    (mkIf (cfg.compositor == "sway") {
      wayland.windowManager.sway.extraConfig = ''
        input "${device}" {
            scroll_method on_button_down
            scroll_button ${button}
            scroll_button_lock ${lockSway}
        }
      '';
    })

    (mkIf (cfg.compositor == "hyprland") {
      wayland.windowManager.hyprland.extraConfig =
        if config.wayland.windowManager.hyprland.configType == "lua" then
          ''
            hl.device({
                name = "${device}",
                scroll_method = "on_button_down",
                scroll_button = ${button},
                scroll_button_lock = ${lockHypr},
            })
          ''
        else
          ''
            device {
                name = ${device}
                scroll_method = on_button_down
                scroll_button = ${button}
                scroll_button_lock = ${lockHypr}
            }
          '';
    })

    (mkIf (cfg.compositor == "gnome") {
      dconf.settings."org/gnome/desktop/peripherals/trackball" = {
        scroll-wheel-emulation-button = cfg.scrollButton;
        scroll-wheel-emulation-button-lock = cfg.scrollButtonLock;
      };
    })

    (mkIf (cfg.compositor == "niri") {
      xdg.configFile."niri/kensington-trackball.kdl".text = ''
        trackball {
            scroll-method "on-button-down"
            scroll-button ${button}
            ${lib.optionalString cfg.scrollButtonLock "scroll-button-lock"}
        }
      '';
      warnings = [
        ''
          The Kensington module generated
          ~/.config/niri/kensington-trackball.kdl. Add
          include "kensington-trackball.kdl" inside the input block of your
          niri config. niri applies it to every trackball.
        ''
      ];
    })
  ]);
}
