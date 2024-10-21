{ config, pkgs ? import <nixpkgs> {} }:

{
  home.packages = with pkgs; [
    google-cloud-sdk
    iterm2
  ];

}
