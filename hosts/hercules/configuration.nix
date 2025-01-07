{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  root = ../..;
  nixos-modules = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    /.${root}/hosts/base.nix
    ./hardware-configuration.nix
    /.${root}/modules/gnome
    /.${root}/modules/virtualisation
    /.${root}/modules/yubikey-for-login
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
  networking.hostName = "hercules";
  time.timeZone = "Europe/London";
  sops.secrets.hercules-password.neededForUsers = true;
  stylix.image = /.${root}/wallpapers/alpine.jpeg;
  stylix.polarity = "light";
  services.fwupd.enable = true; # Firmware update
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = false;
  services.fprintd.enable = pkgs.lib.mkForce false; # fprintd seems broken atm, and I don't use it (it is being set by the hardware module)
}
