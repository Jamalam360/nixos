{
  inputs,
  outputs,
  ...
}: let
  root = ../..;
  nixos-modules = [
    /.${root}/hosts/base.nix
    ./hardware-configuration.nix
    /.${root}/modules/services
  ];
  home-manager-modules = [
    /.${root}/hosts/home_base.nix
  ];
in {
  imports = nixos-modules;

  users.users.root.hashedPassword = "!"; # Disable root login

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

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
  networking.hostName = "ara";
  time.timeZone = "Europe/Helsinki";
  sops.secrets.ara-password.neededForUsers = true;
}
