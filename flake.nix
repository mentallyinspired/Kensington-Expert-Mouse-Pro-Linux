{
  description = "Kensington Expert Mouse Pro setup for Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      homeManagerModules = {
        default = import ./nix/home-manager.nix;
        kensington-expert-mouse-pro = self.homeManagerModules.default;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "kensington-expert-mouse-pro-linux";
            version = "0.1.0";
            src = self;
            installPhase = ''
              runHook preInstall
              mkdir -p "$out/bin" "$out/share/kensington-expert-mouse-pro"
              cp scripts/inspect-device scripts/install-x11 "$out/bin/"
              cp -r docs x11 README.md LICENSE "$out/share/kensington-expert-mouse-pro/"
              runHook postInstall
            '';
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      checks = forAllSystems (system: {
        home-manager-module =
          (home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            modules = [
              self.homeManagerModules.default
              {
                home = {
                  username = "flake-check";
                  homeDirectory = "/home/flake-check";
                  stateVersion = "26.05";
                };
                programs.kensington-expert-mouse-pro = {
                  enable = true;
                  compositor = "sway";
                  device = "1149:4098:Kensington_Kensington_USB/PS2_Trackball";
                  scrollButton = 274;
                };
              }
            ];
          }).activationPackage;
      });
    };
}
