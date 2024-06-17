{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-configuration.nix

    ./../../modules/nixos/base.nix
  ];

  boot.loader.grub.enable = true;

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

  sops.secrets.lyra-password.neededForUsers = true;
  sops.secrets.lyra-password = {};

  networking.hostName = "lyra";
  networking.networkmanager.enable = true;
}
