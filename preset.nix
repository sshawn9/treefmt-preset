{ lib, ... }:
{
  # In a flake-parts project, treefmt-nix uses this marker to find the project
  # root when formatting from a subdirectory. Consumers can override it, for
  # example to ".git/config" or another repository marker.
  #
  # Standalone command runners override this at runtime because they are meant
  # to work in any directory, including directories with no flake.nix.
  projectRootFile = lib.mkDefault "flake.nix";

  # Every value is mkDefault so importing projects can disable or replace any
  # formatter without fighting module priority conflicts.
  programs = {
    # Nix formatter — https://github.com/NixOS/nixfmt
    nixfmt.enable = lib.mkDefault true;

    # Nix dead-code finder and remover — https://github.com/astro/deadnix
    deadnix.enable = lib.mkDefault true;

    # Nix linter / anti-pattern fixer — https://github.com/oppiliappan/statix
    statix.enable = lib.mkDefault true;

    # Python formatter from Astral — https://github.com/astral-sh/ruff
    ruff-format.enable = lib.mkDefault true;

    # C, C++, Objective-C, Java, Protobuf — https://clang.llvm.org/docs/ClangFormat.html
    clang-format.enable = lib.mkDefault true;

    # Rust formatter — https://github.com/rust-lang/rustfmt
    rustfmt.enable = lib.mkDefault true;

    # Lua formatter — https://github.com/JohnnyMorganz/StyLua
    stylua.enable = lib.mkDefault true;

    # Shell scripts: bash, POSIX sh, mksh — https://github.com/mvdan/sh
    shfmt.enable = lib.mkDefault true;

    # JS, TS, JSON, YAML, Markdown, HTML, CSS, GraphQL — https://prettier.io
    prettier.enable = lib.mkDefault true;

    # TOML formatter — https://github.com/tamasfe/taplo
    taplo.enable = lib.mkDefault true;

    # Protocol Buffers (.proto) — https://github.com/bufbuild/buf
    buf.enable = lib.mkDefault true;

    # justfile (https://just.systems) formatter — https://github.com/casey/just
    just.enable = lib.mkDefault true;

    # Dockerfile formatter — https://github.com/reteps/dockerfmt
    #
    # treefmt-nix tags this with meta.brokenPlatforms = lib.platforms.darwin,
    # but that field is informational only (referenced in module-options.nix
    # and the docs/example pipeline; never gates evaluation or build). The
    # actual nixpkgs package builds on Darwin, so enabling unconditionally is
    # safe and gives platform-symmetric output.
    dockerfmt.enable = lib.mkDefault true;
  };
}
