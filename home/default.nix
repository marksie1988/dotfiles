{ config, ... }:
{
  imports = [
    ./options.nix
    ./packages.nix
    ./cli.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./npm-globals.nix
    ./vscode.nix
    ./ghostty.nix
    ./neovim.nix
    ./herdr.nix
  ];

  # home.username / home.homeDirectory are set by the flake's shared module.
  home.stateVersion = "25.05";

  xdg.enable = true;

  # Environment. Replaces .zsh/exports.sh and the EDITOR/KUBE_EDITOR exports.
  home.sessionVariables = {
    EDITOR = "nvim";
    KUBE_EDITOR = "nvim";
    GEM_HOME = "${config.home.homeDirectory}/gems";
    # k9s honours this on every platform (avoids macOS's ~/Library path).
    K9S_CONFIG_DIR = "${config.xdg.configHome}/k9s";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/gems/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  # Raw config files carried into $HOME. With yadm these lived in the repo and
  # were checked out into $HOME directly; under home-manager they must be placed
  # explicitly, so we symlink the verbatim files kept under ../config.
  xdg.configFile = {
    "starship.toml".source = ../config/starship.toml;
    "k9s".source = ../config/k9s;
    "helix".source = ../config/helix;
    "bat/config".source = ../config/bat/config;
    # Only herdr's config.toml — NOT the whole dir. herdr writes logs, sockets and
    # session state into ~/.config/herdr at runtime, so that dir must stay writable.
    "herdr/config.toml".source = ../config/herdr/config.toml;
  };

  # NOTE: ~/.ssh/config (internal hosts) is NOT managed here — it lives in the
  # private overlay repo (dotfiles-priv) so internal network details stay out of
  # this public repo. See that repo's overlay.nix.
}
