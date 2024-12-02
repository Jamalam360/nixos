{
  inputs,
  outputs,
  ...
}: let
  root = ../..;
  nixos-modules = [
    /.${root}/hosts/base.nix
    ./hardware-configuration.nix
    /.${root}/modules/gnome
    /.${root}/modules/nvidia
    /.${root}/modules/virtualisation
  ];
  home-manager-modules = [
    /.${root}/hosts/home_base.nix
    /.${root}/modules/gnome/home.nix
    /.${root}/modules/jdk/home.nix
  ];
in {
  imports = nixos-modules;

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".home_manager_bak";
    users = {
      james = {
        imports = home-manager-modules;
      };
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "leo";
  time.timeZone = "Europe/London";
  sops.secrets.leo-password.neededForUsers = true;
  stylix.image = /.${root}/wallpapers/budapest.png;
  nix.settings.min-free = 1 * 1024 * 1024 * 1024; # 1GiB
}
