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
      # Identity — edit these when cloning onto a new machine.
      username = "stevenmarks";
      # Full name / email live in home/git.nix.

      # home-manager module shared by every platform. Machine-specific bits
      # (macOS defaults, Homebrew casks) live in hosts/*, not here.
      homeModule =
        { pkgs, ... }:
        {
          home.username = username;
          home.homeDirectory =
            if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
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
      # Build with: home-manager switch --flake .#stevenmarks@linux
      homeConfigurations."${username}@linux" = home-manager.lib.homeManagerConfiguration {
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
