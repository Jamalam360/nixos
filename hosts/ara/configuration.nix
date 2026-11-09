{
  inputs,
  outputs,
  pkgs,
  pkgs-stableish,
  ...
}: let
  root = ../..;
  nixos-modules = [
    /.${root}/hosts/base.nix
    ./hardware-configuration.nix
    /.${root}/modules/nix-gc
    /.${root}/modules/services
    /.${root}/modules/syncthing
  ];
  home-manager-modules = [
    /.${root}/hosts/home_base.nix
  ];
in {
  imports = nixos-modules;

  users.users.root.hashedPassword = "!"; # Disable root login

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs pkgs-stableish;};
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
  security.sudo.wheelNeedsPassword = pkgs.lib.mkForce true; # Available over SSH
  sops.secrets.ara-password.neededForUsers = true;
  nix.settings = {
    min-free = pkgs.lib.mkForce (10 * 1024 * 1024 * 1024);
    max-free = 25 * 1024 * 1024 * 1024;
  };
}
