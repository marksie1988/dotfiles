
{ config, pkgs ? import <nixpkgs> {} }:

{
  programs.zsh.enable = true;
  programs.zsh.initExtra = ''
    # Source Zsh plugins
    source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   

  '';
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" ]; 
  };
}
