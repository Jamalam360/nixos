{
  description = "jamalam-nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixcache.jamalam.tech"
    ];
    extra-trusted-public-keys = [
      "nixcache.jamalam.tech:kK0ZbqNEnH1UMq3LJk8EDsLbI1H2K8ooQAqiiU7/5s0="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
      inherit (self) outputs;
    in {
    formatter = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations = {
      hercules = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/hercules/configuration.nix
        ];
      };

      lyra = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/lyra/configuration.nix
        ];
      };

      testvm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/testvm/configuration.nix
        ];
      };
    };
  };
}
