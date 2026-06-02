# treefmt-preset

[![CI](https://github.com/sshawn9/treefmt-preset/actions/workflows/ci.yml/badge.svg)](https://github.com/sshawn9/treefmt-preset/actions/workflows/ci.yml)
[![Renovate](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://github.com/sshawn9/treefmt-preset/issues/1)
[![English](https://img.shields.io/badge/lang-English-blue)](./README.md)
[![简体中文](https://img.shields.io/badge/lang-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-red)](./README.zh-CN.md)

An opinionated treefmt preset and command bundle for Nix users.

This repository is not a fork of `treefmt` or `treefmt-nix`. It is a thin
distribution layer around upstream `treefmt-nix`: one shared formatter preset,
several runnable commands, and small install modules for NixOS, nix-darwin, and
Home Manager.

## What This Solves

`treefmt` is the formatter runner. It reads a `treefmt.toml` file and invokes
language-specific formatters.

`treefmt-nix` is the Nix integration. It can generate a `treefmt.toml`, package
all formatter tools, and produce a wrapper.

`treefmt-preset` gives you a ready-made formatter set in a few different forms:

- `treefmt-preset-helper`: print a complete command guide
- `treefmt-preset`: run the bundled preset anywhere
- `treefmt-preset-export-config`: export the generated preset config to
  `.treefmt.toml`
- `treefmt-auto`: use a local `treefmt.toml` when one exists, otherwise use the
  bundled preset
- `treefmt`: upstream treefmt unchanged, exported for convenience
- `flakeModules.treefmt-preset`: import the preset into a flake-parts project
  and customize it with Nix module merging
- `nixosModules.default`, `darwinModules.default`, `homeModules.default`:
  install the commands declaratively

## Included Formatters

The preset enables thirteen formatters covering the languages this repository
is most commonly asked to format. Every entry is set with `lib.mkDefault`, so
consumers can disable or replace any of them through normal Nix module merging.

| Formatter                                                      | Languages / files                                |
| -------------------------------------------------------------- | ------------------------------------------------ |
| [`nixfmt`](https://github.com/NixOS/nixfmt)                    | Nix                                              |
| [`deadnix`](https://github.com/astro/deadnix)                  | Nix dead-code finder and remover                 |
| [`statix`](https://github.com/oppiliappan/statix)              | Nix linter / anti-pattern fixer                  |
| [`ruff-format`](https://github.com/astral-sh/ruff)             | Python                                           |
| [`clang-format`](https://clang.llvm.org/docs/ClangFormat.html) | C, C++, Objective-C, Java, Protobuf              |
| [`rustfmt`](https://github.com/rust-lang/rustfmt)              | Rust                                             |
| [`stylua`](https://github.com/JohnnyMorganz/StyLua)            | Lua                                              |
| [`shfmt`](https://github.com/mvdan/sh)                         | Shell scripts: bash, POSIX sh, mksh              |
| [`prettier`](https://prettier.io)                              | JS, TS, JSON, YAML, Markdown, HTML, CSS, GraphQL |
| [`taplo`](https://github.com/tamasfe/taplo)                    | TOML                                             |
| [`buf`](https://github.com/bufbuild/buf)                       | Protocol Buffers (`.proto`)                      |
| [`just`](https://github.com/casey/just)                        | `justfile`                                       |
| [`dockerfmt`](https://github.com/reteps/dockerfmt)             | Dockerfile                                       |

All thirteen run on both Linux and Darwin.

## Which Entry Should I Use?

| Want                                                   | Use                                                    |
| ------------------------------------------------------ | ------------------------------------------------------ |
| See the command guide                                  | `nix run github:sshawn9/treefmt-preset`                |
| Run the bundled preset once                            | `nix run github:sshawn9/treefmt-preset#treefmt-preset` |
| Export the bundled preset config                       | `packages.${system}.treefmt-preset-export-config`      |
| Get commands in an interactive shell                   | `nix shell github:sshawn9/treefmt-preset`              |
| Install commands on NixOS                              | `nixosModules.default`                                 |
| Install commands on nix-darwin                         | `darwinModules.default`                                |
| Install commands with Home Manager                     | `homeModules.default`                                  |
| Use Nix-native treefmt config in a flake-parts project | `flakeModules.treefmt-preset`                          |
| Run upstream treefmt from this flake                   | `packages.${system}.treefmt`                           |
| Prefer local `treefmt.toml`, otherwise use the preset  | `packages.${system}.treefmt-auto`                      |

## Commands

This flake exposes five named commands. The default package and app are the
helper, so plain `nix run github:sshawn9/treefmt-preset` is informational and
does not modify files.

| Package                             | Command                        | Behavior                                                                                    |
| ----------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------- |
| `default` / `treefmt-preset-helper` | `treefmt-preset-helper`        | Prints a guide for every command and integration path.                                      |
| `treefmt-preset`                    | `treefmt-preset`               | Always uses the bundled preset. Does not read local `treefmt.toml`.                         |
| `treefmt-preset-export-config`      | `treefmt-preset-export-config` | Writes the generated preset config to `./.treefmt.toml`.                                    |
| `treefmt`                           | `treefmt`                      | Upstream treefmt unchanged. Reads config exactly like treefmt normally does.                |
| `treefmt-auto`                      | `treefmt-auto`                 | Uses local `treefmt.toml` / `.treefmt.toml` when found, otherwise falls back to the preset. |

### Tree Root Selection

`treefmt-preset` and the preset fallback path in `treefmt-auto` need a tree root
because their generated config lives in the Nix store. They choose it in this
order:

1. `TREEFMT_PRESET_ROOT`
2. `PRJ_ROOT`, which is set by `nix fmt`
3. `git rev-parse --show-toplevel`
4. the current working directory

The `treefmt` package does not do this. It is upstream treefmt, so treefmt
performs its normal config and root discovery.

## Quick Run

Print the command guide:

```sh
nix run github:sshawn9/treefmt-preset
```

Run the fixed preset anywhere:

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset
```

Run the local-config-aware command:

```sh
nix run github:sshawn9/treefmt-preset#treefmt-auto
```

Enter a shell with all commands available:

```sh
nix shell github:sshawn9/treefmt-preset
treefmt-preset
treefmt-auto
```

Install into a profile:

```sh
nix profile install github:sshawn9/treefmt-preset
```

Because the default package is the helper, that installs
`treefmt-preset-helper`. To install the formatter command, use:

```sh
nix profile install github:sshawn9/treefmt-preset#treefmt-preset
```

Install upstream `treefmt` from this flake:

```sh
nix profile install github:sshawn9/treefmt-preset#treefmt
```

Export the generated preset config into the current directory:

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config
```

The export command refuses to overwrite an existing `.treefmt.toml`. Use
`--force` to overwrite or `--stdout` to inspect the generated config:

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config -- --stdout
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config -- --force
```

The exported file is the real config generated by `treefmt-nix`, so formatter
commands may point at `/nix/store` paths. Treat it as an inspectable snapshot or
starting point for a hand-written config.

## NixOS

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-preset.url = "github:sshawn9/treefmt-preset";
  };

  outputs = inputs: {
    nixosConfigurations.host = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.treefmt-preset.nixosModules.default
        {
          programs.treefmt-preset = {
            enable = true;
            commands = [
              "treefmt-preset-helper"
              "treefmt-preset"
              "treefmt-preset-export-config"
              "treefmt-auto"
            ];
          };
        }
      ];
    };
  };
}
```

To also install upstream `treefmt`, add `"treefmt"`:

```nix
programs.treefmt-preset.commands = [
  "treefmt-preset-helper"
  "treefmt-preset"
  "treefmt-preset-export-config"
  "treefmt"
  "treefmt-auto"
];
```

## nix-darwin

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-preset.url = "github:sshawn9/treefmt-preset";
  };

  outputs = inputs: {
    darwinConfigurations.mac = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.treefmt-preset.darwinModules.default
        {
          programs.treefmt-preset = {
            enable = true;
            commands = [
              "treefmt-preset-helper"
              "treefmt-preset"
              "treefmt-preset-export-config"
              "treefmt-auto"
            ];
          };
        }
      ];
    };
  };
}
```

## Home Manager

```nix
{
  imports = [
    inputs.treefmt-preset.homeModules.default
  ];

  programs.treefmt-preset = {
    enable = true;
    commands = [
      "treefmt-preset-helper"
      "treefmt-preset"
      "treefmt-preset-export-config"
      "treefmt-auto"
    ];
  };
}
```

## Module Options

The `nixosModules.default`, `darwinModules.default`, and `homeModules.default`
modules all expose the same `programs.treefmt-preset` option set:

<!-- prettier-ignore -->
| Option | Type | Default | Effect |
| --- | --- | --- | --- |
| `enable` | bool | `false` | Master switch. |
| `commands` | list enum | `[ "treefmt-preset" ]` | Which command packages from this flake to install. |
| `includeFormatters` | bool | `true` | Also install every formatter tool the preset enables (`nixfmt`, `deadnix`, `statix`, `ruff`, `clang-format`, `rustfmt`, `stylua`, `shfmt`, `prettier`, `taplo`, `buf`, `just`, `dockerfmt`) so they are reachable as standalone PATH commands, not only inside the `treefmt-preset` wrapper. Set to `false` when these tools are already provided by another module or by a project devShell. |
| `extraPackages` | list pkg | `[ ]` | Additional packages to install alongside the selected commands. |

## Flake-Parts Project Preset

Use this when you want configuration to live in Nix and merge through the Nix
module system.

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-preset.url = "github:sshawn9/treefmt-preset";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      imports = [
        inputs.treefmt-preset.flakeModules.treefmt-preset
      ];

      perSystem = {
        treefmt.config = {
          programs.prettier.enable = false;
          programs.biome.enable = true;

          settings.global.excludes = [
            "vendor/**"
          ];
        };
      };
    };
}
```

This makes `nix fmt` run the generated `treefmt-nix` wrapper for the project.
Overrides happen in Nix. `treefmt` still receives one final generated config
file.

All defaults in [preset.nix](./preset.nix) use `lib.mkDefault`, so consumers can
disable or override individual formatters without priority conflicts.

## Plain `treefmt.toml`

Use `treefmt-auto` when you prefer an ordinary `treefmt.toml` but still want the
preset's formatter tools in `PATH`.

```nix
{
  formatter.${system} =
    inputs.treefmt-preset.packages.${system}.treefmt-auto;
}
```

Then:

```sh
nix fmt
```

will use a nearby `treefmt.toml` / `.treefmt.toml` when one exists. If no local
treefmt config exists, it falls back to `treefmt-preset`.

If you want upstream treefmt with no preset behavior at all, use:

```nix
{
  formatter.${system} = inputs.treefmt-preset.packages.${system}.treefmt;
}
```

That output is exactly upstream treefmt; it does not add this preset's
formatter tools to `PATH`.

## Outputs

This repository uses `flake-parts` internally, but consumers do not need to use
`flake-parts` unless they want `flakeModules.treefmt-preset`.

Standard outputs:

- `packages.${system}.default`
- `packages.${system}.treefmt-preset-helper`
- `packages.${system}.treefmt-preset`
- `packages.${system}.treefmt-preset-export-config`
- `packages.${system}.treefmt`
- `packages.${system}.treefmt-auto`
- `apps.${system}.default`
- `apps.${system}.treefmt-preset-helper`
- `apps.${system}.treefmt-preset`
- `apps.${system}.treefmt-preset-export-config`
- `apps.${system}.treefmt`
- `apps.${system}.treefmt-auto`
- `formatter.${system}`
- `devShells.${system}.default`
- `nixosModules.default`
- `darwinModules.default`
- `homeModules.default`
- `flakeModules.default`
- `flakeModules.treefmt-preset`

Library helpers:

- `lib.presetModule`
- `lib.mkPackages pkgs`
- `lib.evalModule`
- `lib.mkConfigFile`
- `lib.mkWrapper`

## Repository Layout

- [flake.nix](./flake.nix): public flake outputs, built with `flake-parts`
- [preset.nix](./preset.nix): shared treefmt-nix preset
- [packages.nix](./packages.nix): runnable command packages
- [programs-module.nix](./programs-module.nix): NixOS, nix-darwin, and Home
  Manager module that exposes the `programs.treefmt-preset` option namespace

## Naming

`treefmt-preset` is still the intended name. The repository is centered around
one opinionated preset; the commands and modules are delivery mechanisms for
that preset.
