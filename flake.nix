{
  description = "NixOS & Home Manager Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
 	{ nixpkgs.hostPlatform = "x86_64-linux"; }
 	./configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = false;
            backupFileExtension = "bak";
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [
              stylix.homeModules.stylix
            ];
            users.soulirith = {
              imports = [ ./home.nix ];
              nixpkgs.config.allowUnfree = true;
            };
          };
        }
      ];
    };
  };
}
