{ config, lib, ... }:
{
  # ─────────────────────────────────────────────────────────────────────────
  # Feature flags — the customisation surface (replaces the old interactive
  # `optional.sh` prompts). Flip a default here to change what a fresh install
  # gets, or override any of these per-machine in hosts/<host>.nix, e.g.
  #   dotfiles.apps.vscode.enable = false;
  # ─────────────────────────────────────────────────────────────────────────
  options.dotfiles = {
    # Flake the `dfup` helper rebuilds from. Defaults to this (public) repo;
    # a private overlay points it at the overlay flake instead.
    flakeRef = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/repos/personal/dotfiles";
      description = "Path/flake-ref that `dfup` rebuilds from.";
    };

    # For overlay flakes that wrap the public base via a `path:` input: when set,
    # `dfup` passes `--override-input dotfiles path:<this>` so working-tree edits
    # to the public repo are always used (no stale-lock / NAR-hash friction).
    baseFlakePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "If set, dfup overrides the overlay's `dotfiles` input with this local path.";
    };

    # (AI agent instructions are managed by the separate dotfiles-agents repo,
    # not by Nix — see that repo.)
    apps.ghostty.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Manage the Ghostty terminal config.";
    };
    apps.vscode.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install VS Code extensions on activation.";
    };
  };
}
