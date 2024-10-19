{ config, pkgs ? import <nixpkgs> {} }:

{
  home.packages = with pkgs; [
    google-cloud-sdk
    # ... other macOS-specific packages
  ];

  # ... other macOS-specific configuration 
  # (e.g., macOS-specific keybindings, environment variables, etc.)
}
