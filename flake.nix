{
  description = "Steven Marks' dotfiles — nix-darwin + home-manager, cross-platform (macOS + Linux/WSL2)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    let
      # Identity is auto-detected from the environment so this flake works on any
      # machine / for any user without editing. `$USER` and `$HOME` are read with
      # builtins.getEnv, which only returns real values under `--impure` eval — the
      # `dfup` helper and setup/bootstrap.sh pass `--impure` for you. Under pure
      # eval (e.g. CI's `nix flake check`) getEnv returns "", so we fall back to a
      # sane default. Full name / email live in home/git.nix.
      envUser = builtins.getEnv "USER";
      username = if envUser != "" then envUser else "stevenmarks";

      # home-manager module shared by every platform. Machine-specific bits
      # (macOS defaults, Homebrew casks) live in hosts/*, not here.
      homeModule =
        { pkgs, ... }:
        {
          home.username = username;
          home.homeDirectory =
            let
              envHome = builtins.getEnv "HOME";
            in
            if envHome != "" then
              envHome
            else if pkgs.stdenv.isDarwin then
              "/Users/${username}"
            else
              "/home/${username}";
          imports = [ ./home ];
        };

      # Reusable nix-darwin module: system config + home-manager wiring. Exported
      # as darwinModules.default so a private overlay flake can build on top of it
      # (see the dotfiles-priv repo). The standalone config below uses it too.
      darwinModule = {
        imports = [
          ./hosts/darwin.nix
          home-manager.darwinModules.home-manager
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        # Back up (don't clobber) any pre-existing files home-manager manages.
        home-manager.backupFileExtension = "bak";
        home-manager.users.${username} = homeModule;
        home-manager.extraSpecialArgs = { inherit username; };
      };
    in
    {
      # Exposed for a private overlay flake to reuse.
      darwinModules.default = darwinModule;
      homeModules.default = homeModule;

      # macOS: standalone config (no private overlay). Used by anyone who clones
      # this repo directly; your own Mac builds the private flake instead.
      darwinConfigurations."Stevens-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };
        modules = [ darwinModule ];
      };

      # Linux / WSL2: standalone home-manager on top of the existing distro.
      # Named generically (not per-user) so the command is identical on every
      # machine — the actual user is auto-detected (see `username` above).
      # Build with: home-manager switch --impure --flake .#linux
      homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit username; };
        modules = [ homeModule ];
      };

      # `nix fmt` — format all Nix files in the tree.
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
