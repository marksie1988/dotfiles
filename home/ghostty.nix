{ config, lib, ... }:
{
  # Ghostty is installed as a Homebrew cask (see hosts/darwin.nix); here we only
  # manage its config, symlinked to ~/.config/ghostty/config (Ghostty reads XDG
  # on macOS and Linux). Written as a raw file so it's independent of any
  # home-manager module version.
  xdg.configFile."ghostty/config" = lib.mkIf config.dotfiles.apps.ghostty.enable {
    text = ''
      # Tokyo Night — matches starship / tmux / fzf / k9s / helix
      theme = tokyonight

      font-family = Hack Nerd Font Mono
      font-size = 13

      cursor-style = block
      mouse-hide-while-typing = true
      macos-option-as-alt = true
      window-save-state = always
      confirm-close-surface = false
    '';
  };
}
