# treefmt-preset

[![English](https://img.shields.io/badge/lang-English-blue)](./README.md)
[![简体中文](https://img.shields.io/badge/lang-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-red)](./README.zh-CN.md)

面向 Nix 用户的自带观点的 treefmt 预设和命令集合。

这个仓库不是 `treefmt` 或 `treefmt-nix` 的 fork。它是上游
`treefmt-nix` 外面的一层轻量分发：一个共享 formatter 预设、几个可运行
命令，以及用于 NixOS、nix-darwin 和 Home Manager 的小型安装模块。

## 它解决什么问题

`treefmt` 是 formatter runner。它读取 `treefmt.toml` 文件，然后调用具体
语言的 formatter。

`treefmt-nix` 是 Nix 集成。它可以生成 `treefmt.toml`，打包所有 formatter
工具，并产出 wrapper。

`treefmt-preset` 用几种不同形式给你一套开箱即用的 formatter 集合：

- `treefmt-preset-helper`：打印完整命令指南
- `treefmt-preset`：在任何地方运行内置预设
- `treefmt-preset-export-config`：把生成的预设配置导出到 `.treefmt.toml`
- `treefmt-auto`：如果存在本地 `treefmt.toml` 就使用它，否则使用内置预设
- `treefmt`：原样导出的上游 treefmt，方便直接使用
- `flakeModules.treefmt-preset`：把预设导入 flake-parts 项目，并通过 Nix
  module merging 自定义
- `nixosModules.default`、`darwinModules.default`、`homeModules.default`：
  声明式安装命令

## 包含的 Formatters

这个预设启用了十三个 formatter，覆盖这个仓库最常被要求格式化的语言。每个
条目都用 `lib.mkDefault` 设置，所以使用者可以通过普通的 Nix module merging
禁用或替换任意 formatter。

| Formatter                                                     | 语言 / 文件                                      |
| ------------------------------------------------------------- | ------------------------------------------------ |
| [`nixfmt`](https://github.com/NixOS/nixfmt)                   | Nix                                              |
| [`deadnix`](https://github.com/astro/deadnix)                 | Nix 死代码查找和移除                             |
| [`statix`](https://github.com/oppiliappan/statix)             | Nix linter / 反模式修复器                        |
| [`ruff-format`](https://github.com/astral-sh/ruff)            | Python                                           |
| [`clang-format`](https://clang.llvm.org/docs/ClangFormat.html) | C, C++, Objective-C, Java, Protobuf             |
| [`rustfmt`](https://github.com/rust-lang/rustfmt)             | Rust                                             |
| [`stylua`](https://github.com/JohnnyMorganz/StyLua)           | Lua                                              |
| [`shfmt`](https://github.com/mvdan/sh)                        | Shell 脚本：bash、POSIX sh、mksh                 |
| [`prettier`](https://prettier.io)                             | JS, TS, JSON, YAML, Markdown, HTML, CSS, GraphQL |
| [`taplo`](https://github.com/tamasfe/taplo)                   | TOML                                             |
| [`buf`](https://github.com/bufbuild/buf)                      | Protocol Buffers (`.proto`)                      |
| [`just`](https://github.com/casey/just)                       | `justfile`                                       |
| [`dockerfmt`](https://github.com/reteps/dockerfmt)            | Dockerfile                                       |

十三个 formatter 都可以在 Linux 和 Darwin 上运行。

## 我该用哪个入口？

| 需求                                                   | 使用                                                   |
| ------------------------------------------------------ | ------------------------------------------------------ |
| 查看命令指南                                           | `nix run github:sshawn9/treefmt-preset`                |
| 运行一次内置预设                                       | `nix run github:sshawn9/treefmt-preset#treefmt-preset` |
| 导出内置预设配置                                       | `packages.${system}.treefmt-preset-export-config`      |
| 进入带有全部命令的交互 shell                           | `nix shell github:sshawn9/treefmt-preset`              |
| 在 NixOS 上安装命令                                    | `nixosModules.default`                                 |
| 在 nix-darwin 上安装命令                               | `darwinModules.default`                                |
| 通过 Home Manager 安装命令                             | `homeModules.default`                                  |
| 在 flake-parts 项目中使用 Nix-native treefmt 配置      | `flakeModules.treefmt-preset`                          |
| 从这个 flake 运行上游 treefmt                          | `packages.${system}.treefmt`                           |
| 优先使用本地 `treefmt.toml`，否则使用预设              | `packages.${system}.treefmt-auto`                      |

## 命令

这个 flake 暴露五个具名命令。默认 package 和 app 是 helper，所以直接运行
`nix run github:sshawn9/treefmt-preset` 只会显示信息，不会修改文件。

| Package                             | Command                        | 行为                                                                                        |
| ----------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------- |
| `default` / `treefmt-preset-helper` | `treefmt-preset-helper`        | 打印每个命令和集成路径的指南。                                                              |
| `treefmt-preset`                    | `treefmt-preset`               | 始终使用内置预设。不读取本地 `treefmt.toml`。                                                |
| `treefmt-preset-export-config`      | `treefmt-preset-export-config` | 把生成的预设配置写入 `./.treefmt.toml`。                                                     |
| `treefmt`                           | `treefmt`                      | 原样使用上游 treefmt。按 treefmt 的正常规则读取配置。                                        |
| `treefmt-auto`                      | `treefmt-auto`                 | 如果找到本地 `treefmt.toml` / `.treefmt.toml` 就使用它，否则回退到预设。                    |

### Tree Root 选择

`treefmt-preset` 和 `treefmt-auto` 中的预设回退路径需要一个 tree root，因为它们
生成的配置在 Nix store 里。选择顺序如下：

1. `TREEFMT_PRESET_ROOT`
2. `PRJ_ROOT`，由 `nix fmt` 设置
3. `git rev-parse --show-toplevel`
4. 当前工作目录

`treefmt` package 不做这件事。它是上游 treefmt，所以 treefmt 会执行自己的正常
配置和 root 发现逻辑。

## 快速运行

打印命令指南：

```sh
nix run github:sshawn9/treefmt-preset
```

在任何地方运行固定预设：

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset
```

运行会感知本地配置的命令：

```sh
nix run github:sshawn9/treefmt-preset#treefmt-auto
```

进入包含所有命令的 shell：

```sh
nix shell github:sshawn9/treefmt-preset
treefmt-preset
treefmt-auto
```

安装到 profile：

```sh
nix profile install github:sshawn9/treefmt-preset
```

因为默认 package 是 helper，这会安装 `treefmt-preset-helper`。要安装 formatter
命令，请使用：

```sh
nix profile install github:sshawn9/treefmt-preset#treefmt-preset
```

从这个 flake 安装上游 `treefmt`：

```sh
nix profile install github:sshawn9/treefmt-preset#treefmt
```

把生成的预设配置导出到当前目录：

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config
```

导出命令拒绝覆盖已存在的 `.treefmt.toml`。使用 `--force` 覆盖，或用
`--stdout` 查看生成配置：

```sh
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config -- --stdout
nix run github:sshawn9/treefmt-preset#treefmt-preset-export-config -- --force
```

导出的文件是由 `treefmt-nix` 生成的真实配置，所以 formatter 命令可能指向
`/nix/store` 路径。可以把它当作可检查的快照，或者手写配置的起点。

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

如果还想安装上游 `treefmt`，加入 `"treefmt"`：

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

## 模块选项

`nixosModules.default`、`darwinModules.default` 和 `homeModules.default` 模块
都暴露同一套 `programs.treefmt-preset` 选项：

| 选项                | 类型      | 默认值               | 效果                                                                                                                                                                            |
| ------------------- | --------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `enable`            | bool      | `false`              | 总开关。                                                                                                                                                                        |
| `commands`          | list enum | `[ "treefmt-preset" ]` | 要安装这个 flake 中的哪些命令 package。                                                                                                                                         |
| `includeFormatters` | bool      | `true`               | 同时安装预设启用的每个 formatter 工具（`nixfmt`、`deadnix`、`statix`、`ruff`、`clang-format`、`rustfmt`、`stylua`、`shfmt`、`prettier`、`taplo`、`buf`、`just`、`dockerfmt`），让它们作为独立命令也能在 PATH 中找到，而不只是存在于 `treefmt-preset` wrapper 内。如果这些工具已经由另一个模块或项目 devShell 提供，可以设为 `false`。 |
| `extraPackages`     | list pkg  | `[ ]`                | 和选中的命令一起额外安装的 package。                                                                                                                                            |

## Flake-Parts 项目预设

如果你希望配置写在 Nix 里，并通过 Nix module system 合并，使用这个入口。

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

这会让 `nix fmt` 运行为项目生成的 `treefmt-nix` wrapper。覆盖在 Nix 中完成。
`treefmt` 仍然只接收一个最终生成出来的配置文件。

[preset.nix](./preset.nix) 中的所有默认值都使用 `lib.mkDefault`，所以使用者可以
禁用或覆盖单个 formatter，而不会遇到优先级冲突。

## 普通 `treefmt.toml`

如果你更喜欢普通的 `treefmt.toml`，但仍然希望预设中的 formatter 工具出现在
`PATH` 中，可以使用 `treefmt-auto`。

```nix
{
  formatter.${system} =
    inputs.treefmt-preset.packages.${system}.treefmt-auto;
}
```

然后：

```sh
nix fmt
```

会在附近存在 `treefmt.toml` / `.treefmt.toml` 时使用它。如果不存在本地 treefmt
配置，则回退到 `treefmt-preset`。

如果你想使用完全没有预设行为的上游 treefmt，使用：

```nix
{
  formatter.${system} = inputs.treefmt-preset.packages.${system}.treefmt;
}
```

这个输出就是上游 treefmt；它不会把这个预设的 formatter 工具加入 `PATH`。

## Outputs

这个仓库内部使用 `flake-parts`，但使用者不需要使用 `flake-parts`，除非他们想用
`flakeModules.treefmt-preset`。

标准 outputs：

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

库 helpers：

- `lib.presetModule`
- `lib.mkPackages pkgs`
- `lib.evalModule`
- `lib.mkConfigFile`
- `lib.mkWrapper`

## 仓库结构

- [flake.nix](./flake.nix)：公开 flake outputs，基于 `flake-parts` 构建
- [preset.nix](./preset.nix)：共享 treefmt-nix 预设
- [packages.nix](./packages.nix)：可运行的命令 packages
- [programs-module.nix](./programs-module.nix)：NixOS、nix-darwin 和 Home
  Manager 模块，暴露 `programs.treefmt-preset` 选项命名空间

## 命名

`treefmt-preset` 仍然是预期名称。这个仓库围绕一个自带观点的预设；命令和模块
都是这个预设的分发机制。
