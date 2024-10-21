
{ config, pkgs ? import <nixpkgs> {} }:

{
  home.packages = with pkgs; [
    git

    # Shell nad tools
    zsh
    starship
    eza
    helix
    curl
    uzinp
    wget
    jq
    kubectl
    helm

    # JS
    nodejs
    yarn
  ];

  home.file.".zshenv" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh/.zshenv";
  }

  xdg.configFile = {
    "git" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/git";
      recursive = true;
    }
    "zsh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh";
      recursive = true;
    }
    "nix" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nix";
    }
  }

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
