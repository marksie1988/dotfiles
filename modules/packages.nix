
{ config, pkgs ? import <nixpkgs> {} }:

{
  home.packages = with pkgs; [
    helix
    curl
    uzinp
    wget
    jq
    starship
    eza
    git
    kubectl
    helm
  ];
}
