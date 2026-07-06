{ ... }:
{
  # CLI tools with dedicated home-manager modules. Shell integration is disabled
  # here and driven manually from zsh.nix so the init order matches the old
  # zshrc.sh exactly (notably: zoxide must initialise after starship).

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # keybindings/completion; order-independent
    # Tokyo Night palette (was FZF_DEFAULT_OPTS in .zsh/fzf.sh)
    colors = {
      "bg+" = "#283457";
      "bg" = "#16161e";
      "spinner" = "#ff9e64";
      "hl" = "#7aa2f7";
      "fg" = "#c0caf5";
      "header" = "#7aa2f7";
      "info" = "#e0af68";
      "pointer" = "#ff9e64";
      "marker" = "#ff9e64";
      "fg+" = "#c0caf5";
      "prompt" = "#7aa2f7";
      "hl+" = "#7aa2f7";
    };
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
    # Use ripgrep as the file source (was FZF_DEFAULT_COMMAND).
    defaultCommand = ''rg --files --hidden --follow -g "!.git"'';
    fileWidgetCommand = ''rg --files --hidden --follow -g "!.git"'';
  };

  programs.ripgrep = {
    enable = true;
    # Was ~/.ripgreprc; sets RIPGREP_CONFIG_PATH automatically.
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git/*"
      "--max-columns=200"
      "--max-columns-preview"
    ];
  };

  programs.eza.enable = true; # binary only; ls/ll/tree aliases live in zsh.nix

  # Prompt + shell integrations — installed here, evaluated (in order) by zsh.nix.
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    # settings left empty on purpose: the verbatim starship.toml is symlinked
    # via xdg.configFile in home/default.nix.
  };

  # zoxide/atuin/starship are init'd manually in zsh.nix (with their flags) so
  # zoxide loads last; here we only install them.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };
}
