{
  description = "My System Flake";
  inputs = {
   # nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
   # home-manager.url = "github:nix-community/home-manager/release-26.05";
 
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";


    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
  ./configuration.nix
  home-manager.nixosModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.users.soulirith = import ./home.nix;
    home-manager.extraSpecialArgs = { inherit inputs; };
  }
      ];
    };
  };
}

