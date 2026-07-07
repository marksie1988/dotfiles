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

  # Non-NixOS desktops (KDE, GNOME, …) only scan ~/.local/share and the system
  # dirs for app launchers — not the Nix profile — so a Nix-installed GUI app
  # never shows up in the menu. Mirror ghostty's .desktop entry + icons into
  # ~/.local/share here. The entry's Exec is an absolute /nix/store path, so it
  # launches without ghostty being on the graphical session's PATH.
  xdg.dataFile = lib.mkIf (config.dotfiles.apps.ghostty.enable && pkgs.stdenv.isLinux) {
    "applications/com.mitchellh.ghostty.desktop".source =
      "${pkgs.ghostty}/share/applications/com.mitchellh.ghostty.desktop";
    "icons/hicolor/128x128/apps/com.mitchellh.ghostty.png".source =
      "${pkgs.ghostty}/share/icons/hicolor/128x128/apps/com.mitchellh.ghostty.png";
    "icons/hicolor/256x256/apps/com.mitchellh.ghostty.png".source =
      "${pkgs.ghostty}/share/icons/hicolor/256x256/apps/com.mitchellh.ghostty.png";
  };

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
