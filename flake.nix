{
  description = "NixOS & Home Manager Flake Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cachix.org"
      "https://cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "blender-bin.cachix.org-1:7I8KioTz8idw59f23vNidOInV9GfFsc6pP0uC95W8M0="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, claude-desktop, blender-bin, ... }@inputs: {
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
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = { inherit inputs; }; 
            sharedModules = [
              stylix.homeModules.stylix
            ];
            users.soulirith = {
              imports = [ ./home.nix ];
              nixpkgs.system = "x86_64-linux";
              nixpkgs.config.allowUnfree = true;
            };
          };
        }
      ];
    };
  };
}

