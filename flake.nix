{
  description = "My Dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles.url = "github:marksie1988/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager }:
    let 
      system   
 = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
      isMacOS = system == "x86_64-darwin";
    in {
      homeConfigurations."my-machine" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          # Import Home Manager modules
          home-manager.modules.programs.zsh 
          home-manager.modules.home.file

          {
            # Auto update and rebuild on changes
            home.activationTriggers = [
              # Trigger on changes to the dotfiles repo
              dotfiles.rev
            ]

            home.postActivation = ''
              echo "Dotfiles updated and rebuilt!"
            '';
          }

          # Your custom modules
          ./modules/packages.nix
          ./modules/zsh.nix
          ./modules/dotfiles.nix 

          # Conditional module for macOS
          (if isMacOS then ./modules/macos/default.nix else ./modules/ubuntu/default.nix)
        ];
      };
    };
}
