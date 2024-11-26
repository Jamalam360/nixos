{
  description = "jamalam-nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sculk = {
      url = "github:sculk-cli/sculk?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    nixosConfigurations = {
      hercules = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/hercules/configuration.nix
          inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
          inputs.stylix.nixosModules.stylix
        ];
      };

      leo = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.stylix.nixosModules.stylix
          ./machines/leo/configuration.nix
        ];
      };

      lyra = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./machines/lyra/configuration.nix
          inputs.stylix.nixosModules.stylix
        ];
      };
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nil # nix language server
        statix # used in CI
        nix-prefetch-github # used in CI
      ];
    };
  };
}
