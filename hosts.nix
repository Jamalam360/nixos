{
  inputs,
  outputs,
  nixpkgs,
  ...
}: let
  mkHosts = hosts:
    builtins.listToAttrs (builtins.concatMap (host: [
        {
          inherit (host) name;
          value = nixpkgs.lib.nixosSystem {
            inherit (host) modules;
            specialArgs = {inherit inputs outputs;};
          };
        }
        {
          name = "${host.name}-iso";
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
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
    {
      name = "lyra";
      modules = [
        ./hosts/lyra/configuration.nix
      ];
    }
  ];
in
  mkHosts hosts
