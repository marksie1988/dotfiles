{ pkgs, config, ... }:
{
  # Kickstart-style Neovim. Plugins are managed by lazy.nvim at runtime (see
  # config/nvim/init.lua); Nix provides Neovim itself plus the build tools that
  # treesitter, telescope-fzf-native and Mason need to compile/install things.
  home.packages = with pkgs; [
    neovim
    gcc # C compiler for treesitter parsers + telescope-fzf-native
    gnumake # `make` for telescope-fzf-native
    fd # faster file source for telescope
    # git, ripgrep, nodejs, curl, unzip are already provided elsewhere.
  ];

  # Out-of-store symlink to the repo working tree (NOT a read-only /nix/store copy):
  # edits to config/nvim/init.lua are live with no `dfup`, and lazy.nvim can write
  # its lazy-lock.json back into the repo. Costs reproducibility/rollback for nvim
  # and hardwires the repo path — acceptable for a config hacked on constantly.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.repoPath}/config/nvim";
}
