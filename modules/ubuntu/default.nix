{ config, pkgs ? import <nixpkgs> {} }:

{
  # ... Ubuntu-specific configuration (if needed)
  home.packages = with pkgs; [
    tmux
  ]
}
