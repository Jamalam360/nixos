{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/audio.nix
    ./../../modules/nixos/desktop_environment.nix
    ./../../modules/nixos/overlays.nix
    ./../../modules/nixos/virtualisation.nix
  ];

  # == System Configuration ==
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "leo";
  time.timeZone = "Europe/London";

  # == Home Manager ==
  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".home_manager_bak";
    users = {
      james = {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/desktops/desktops.nix
        ];
      };
    };
  };

  # == Secrets ==
  sops.secrets = {
    leo-password = {
      neededForUsers = true;
    };

    desktops-env-vars = {
      owner = "james";
      path = "/var/lib/env_vars";
    };
  };

  # == Yubikey ==
  services.pcscd.enable = true;
}
