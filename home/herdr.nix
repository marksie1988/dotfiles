{ lib, pkgs, ... }:
{
  # herdr — agent multiplexer (https://herdr.dev). Not in nixpkgs.
  #   macOS: installed via the fast prebuilt Homebrew bottle (hosts/darwin.nix).
  #   Linux: no bottle, and the upstream Nix flake builds from source (Rust+Zig,
  #     no binary cache) — slow. So we run the official installer, which drops a
  #     prebuilt binary into ~/.local/bin (already on sessionPath). Network
  #     required; tracks "latest" (not pinned), like gemini-cli / no-mistakes.
  home.activation.herdr = lib.mkIf pkgs.stdenv.isLinux (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "$HOME/.local/bin/herdr" ]; then
        run sh -c "${pkgs.curl}/bin/curl -fsSL https://herdr.dev/install.sh | sh"
      fi
    ''
  );
}
