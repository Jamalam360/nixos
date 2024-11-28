{
  inputs,
  outputs,
  ...
}: let
  root = ../..;
  nixos-modules = [
    /.${root}/hosts/base.nix
    ./hardware-configuration.nix
    ./disk-configuration.nix
    /.${root}/modules/lyra-services
  ];
  home-manager-modules = [
    /.${root}/hosts/home_base.nix
  ];
in {
  imports = nixos-modules;

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      james = {
        imports = home-manager-modules;
      };
    };
  };

  boot.loader.grub.enable = true;
  networking.hostName = "lyra";
  time.timeZone = "Europe/Berlin";
  sops.secrets.lyra-password.neededForUsers = true;
}
