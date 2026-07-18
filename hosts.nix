{
  inputs,
  outputs,
  nixpkgs,
  ...
}: let
  system = builtins.currentSystem or "x86_64-linux";
  specialArgs = {
    inherit inputs outputs;
    pkgs-stableish = import inputs.nixpkgs-stableish {
      inherit system;
      config.allowUnfree = true;
    };
  };

  mkHosts = hosts:
    builtins.listToAttrs (builtins.concatMap (host: [
        {
          inherit (host) name;
          value = nixpkgs.lib.nixosSystem {
            inherit (host) modules;
            inherit specialArgs;
          };
        }
        {
          name = "${host.name}-iso";
          value = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules =
              host.modules
              ++ [
                ({
                  pkgs,
                  modulesPath,
                  ...
                }: {
                  imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];
                })
              ];
          };
        }
      ])
      hosts);

  hosts = [
    {
      name = "ara";
      modules = [
        ./hosts/ara/configuration.nix
      ];
    }
    {
      name = "hercules";
      modules = [
        ./hosts/hercules/configuration.nix
      ];
    }
    {
      name = "leo";
      modules = [
        ./hosts/leo/configuration.nix
      ];
    }
  ];
in
  mkHosts hosts
