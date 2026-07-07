{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Ghostty terminal. On macOS the app is a Homebrew cask (see hosts/darwin.nix)
  # because nixpkgs' ghostty is Linux-only (unsupported on darwin); on Linux we
  # install it straight from nixpkgs. Either way the config below is managed and
  # symlinked to ~/.config/ghostty/config (Ghostty reads XDG on macOS and Linux).
  home.packages = lib.optionals (config.dotfiles.apps.ghostty.enable && pkgs.stdenv.isLinux) [
    pkgs.ghostty
  ];

  # Written as a raw file so it's independent of any home-manager module version.
  xdg.configFile."ghostty/config" = lib.mkIf config.dotfiles.apps.ghostty.enable {
    text = ''
      theme = Rose Pine Moon

      font-family = Hack Nerd Font Mono
      font-size = 15

      # Translucent, blurred window (macOS)
      background-opacity = 0.8
      background-blur = 50
      macos-titlebar-style = tabs

      cursor-style = block
      mouse-hide-while-typing = true
      macos-option-as-alt = true
      window-save-state = always
      confirm-close-surface = false
    '';
  };
}
