{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/leo/_packages.nix
  ];

  nixpkgs.overlays = [
    inputs.sculk.overlay
  ];

  # == System Configuration ==
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "leo";
  networking.networkmanager.enable = true;
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
  sops.secrets.leo-password = {
    neededForUsers = true;
  };

  sops.secrets.desktops-env-vars = {
    owner = "james";
    path = "/var/lib/env_vars";
  };

  # == Flatpak ==
  services.flatpak.enable = true;

  # == Desktop ==
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  services.printing.enable = true;
  console.useXkbConfig = true;

  # == Yubikey ==
  services.pcscd.enable = true;

  # == Audio ==
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
