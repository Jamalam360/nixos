{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix

    ./../../services/reposilite.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      james = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  sops.secrets.testvm-password.neededForUsers = true;
  sops.secrets.testvm-password = {};

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "testvm";

  services.reposilite = {
    enable = true;
    package = import ../../custom-reposilite.nix { inherit (inputs) stdenv makeWrapper openjdk17_headless; };
    settings = {
      port = 8084;
    };
  };
}
