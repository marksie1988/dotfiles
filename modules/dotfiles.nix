{ config, pkgs ? import <nixpkgs> {} }:

{
  home.file.".zshrc".source = ./config/zshrc;
  home.file.".config/helix".source = ./config/helix;
  home.file.".config/starship.toml".source = ./config/starship.toml;
  home.file.".ssh".source = ./config/ssh;
}
