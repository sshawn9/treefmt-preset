{
  self,
  # The target option receives the selected package list. NixOS and nix-darwin
  # use environment.systemPackages; Home Manager uses home.packages.
  targetOption,
  targetDescription,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.treefmt-preset;
  inherit (pkgs.stdenv.hostPlatform) system;

  # Use this flake's package output for the host system. This lets the same
  # module work on Linux and Darwin without importing nixpkgs itself.
  packages = self.packages.${system};
  commandNames = [
    "treefmt"
    "treefmt-auto"
    "treefmt-preset"
    "treefmt-preset-export-config"
    "treefmt-preset-helper"
  ];

  # Resolve the formatter packages the preset actually enables for this pkgs.
  # Re-evaluating preset.nix here keeps the formatter set in sync with the
  # preset definition itself, instead of hard-coding a parallel list that could
  # drift when preset.nix changes.
  presetEval = self.lib.evalModule pkgs {
    imports = [ self.lib.presetModule ];
    projectRootFile = null;
  };
  formatterPackages = builtins.attrValues presetEval.config.build.programs;

  selectedPackages =
    (map (name: packages.${name}) cfg.commands)
    ++ lib.optionals cfg.includeFormatters formatterPackages
    ++ cfg.extraPackages;
in
{
  options.programs.treefmt-preset = {
    enable = lib.mkEnableOption "the treefmt-preset formatter commands";

    commands = lib.mkOption {
      type = lib.types.listOf (lib.types.enum commandNames);
      default = [ "treefmt-preset" ];
      example = [
        "treefmt-preset"
        "treefmt-auto"
      ];
      description = ''
        Commands from this flake to install into ${targetDescription}.

        `treefmt-preset-helper` prints a command guide.
        `treefmt-preset` always uses the bundled preset.
        `treefmt-preset-export-config` writes the generated preset config to
        .treefmt.toml in the current directory.
        `treefmt` is upstream treefmt unchanged.
        `treefmt-auto` reads a local treefmt.toml when present and falls back to
        the preset otherwise.
      '';
    };

    # Default true because the obvious user expectation when installing a
    # formatter bundle is that the underlying tools (nixfmt, prettier, ruff,
    # ...) are also reachable from the shell, not only invokable through the
    # treefmt-preset wrapper.
    includeFormatters = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to also install every formatter tool that the preset enables
        (for example nixfmt, deadnix, statix, ruff, prettier, shfmt, taplo)
        into ${targetDescription}, so they are usable as standalone commands
        on PATH and not only inside the treefmt-preset wrapper.

        Set to false to keep ${targetDescription} minimal when these tools
        are already provided by another module or a project devShell.
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install alongside treefmt-preset.";
    };
  };

  # Generate either:
  #   { environment.systemPackages = selectedPackages; }
  # or:
  #   { home.packages = selectedPackages; }
  #
  # Keeping the target as data avoids nearly identical NixOS, nix-darwin, and
  # Home Manager module files.
  config = lib.mkIf cfg.enable (
    lib.setAttrByPath (lib.splitString "." targetOption) selectedPackages
  );
}
