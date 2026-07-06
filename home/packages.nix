{ pkgs, ... }:
{
  # CLI tools that don't need a dedicated `programs.*` module (those live in
  # cli.nix, which installs their package and wires up shell integration).
  # This replaces every script under the old .zsh/installers/.
  # (herdr is cross-platform: Homebrew bottle on macOS via hosts/darwin.nix,
  # official installer on Linux via home/herdr.nix.)
  home.packages = with pkgs; [
    # Core utilities (were MANDATORY_PACKAGES)
    jq
    wget
    curl
    unzip
    coreutils
    openssl
    dnsutils # `dig`, used by the `pip` (public IP) alias

    # Git TUI + hub (git `open` alias)
    lazygit
    hub

    # Editor, k9s, bat — installed as packages; their config is symlinked
    # verbatim from ../config (see home/default.nix). bat's config uses repeated
    # --map-syntax flags, which the programs.bat module can't express, so we
    # symlink it rather than generate it.
    helix
    k9s
    bat

    # Kubernetes / IaC / automation
    kubectl
    kubernetes-helm
    opentofu
    ansible

    # Language runtimes — replace nvm/rbenv with Nix-pinned versions
    nodejs
    ruby
    pnpm

    # Crypto / GPG
    gnupg

    # Fetch tool (neofetch alias points here)
    fastfetch

    # Nix dev tooling (used by `nix fmt` / pre-commit)
    nixfmt-rfc-style
    statix
    deadnix
  ];
}
