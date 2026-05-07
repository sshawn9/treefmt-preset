{
  description = "Opinionated treefmt-nix preset bundling a multi-language formatter set";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Keep the public package/app surface available on the common Nix systems.
      # The preset itself disables individual formatter programs when upstream
      # treefmt-nix marks them unsupported on a platform.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        let
          # Build all command packages once per system, then reuse the same
          # attrset for packages, apps, formatter, and the dev shell.
          packages = import ./packages.nix {
            inherit pkgs treefmt-nix;
          };

          # `nix run .#name` consumes app records. The actual executables live in
          # `packages`; apps are only a friendly launch surface with descriptions.
          mkApp = packageName: programName: description: {
            type = "app";
            program = "${packages.${packageName}}/bin/${programName}";
            meta.description = description;
          };
        in
        {
          inherit packages;

          apps = {
            default = mkApp "treefmt-preset-helper" "treefmt-preset-helper" "Explain treefmt-preset commands";
            treefmt = mkApp "treefmt" "treefmt" "Run upstream treefmt unchanged";
            treefmt-preset = mkApp "treefmt-preset" "treefmt-preset" "Run the bundled treefmt preset";
            treefmt-preset-export-config =
              mkApp "treefmt-preset-export-config" "treefmt-preset-export-config"
                "Export the bundled preset config to .treefmt.toml";
            treefmt-auto =
              mkApp "treefmt-auto" "treefmt-auto"
                "Run local treefmt.toml or fall back to the preset";
            treefmt-preset-helper =
              mkApp "treefmt-preset-helper" "treefmt-preset-helper"
                "Explain treefmt-preset commands";
          };

          formatter = packages.treefmt-preset;

          # Useful while developing this flake: all exposed commands are on PATH.
          devShells.default = pkgs.mkShell {
            packages = [
              packages.treefmt
              packages.treefmt-preset
              packages.treefmt-preset-export-config
              packages.treefmt-auto
              packages.treefmt-preset-helper
            ];
          };
        };

      flake =
        let
          # This is the project-level flake-parts module exported to consumers.
          # It imports treefmt-nix and then applies our shared preset. Users can
          # still override anything because preset.nix uses mkDefault.
          flakeModule = {
            imports = [
              treefmt-nix.flakeModule
            ];

            # `treefmt` is declared as a submodule option by treefmt-nix's
            # flake-module. The submodule's module body accepts the structural
            # NixOS keyword `imports`, which composes additional treefmt-nix
            # modules into it. Writing `treefmt.config.imports` instead would
            # be interpreted as setting an option named `treefmt.imports`,
            # which does not exist and breaks evaluation in the consuming
            # flake-parts project.
            perSystem = _: {
              treefmt.imports = [
                ./preset.nix
              ];
            };
          };

          # NixOS and nix-darwin both install packages through
          # environment.systemPackages, so they can share the same module.
          systemModule = import ./programs-module.nix {
            inherit self;
            targetOption = "environment.systemPackages";
            targetDescription = "the system profile";
          };

          homeModule = import ./programs-module.nix {
            inherit self;
            targetOption = "home.packages";
            targetDescription = "the Home Manager profile";
          };
        in
        {
          lib = {
            # Stable handles for users who want to compose the lower-level bits
            # without going through our flake-parts module or command packages.
            presetModule = ./preset.nix;
            mkPackages =
              pkgs:
              import ./packages.nix {
                inherit pkgs treefmt-nix;
              };

            inherit (treefmt-nix.lib)
              evalModule
              mkConfigFile
              mkWrapper
              ;
          };

          flakeModules = {
            default = flakeModule;
            treefmt-preset = flakeModule;
          };

          nixosModules.default = systemModule;
          darwinModules.default = systemModule;
          homeModules.default = homeModule;
        };
    };
}
