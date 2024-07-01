{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/hercules/_packages.nix
  ];

  nixpkgs.overlays = [
    inputs.sculk.overlay
  ];

  # == System Configuration ==
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hercules";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";

  # == Home Manager ==
  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      james = {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/hercules/hercules.nix
        ];
      };
    };
  };

  # == Secrets ==
  sops.secrets.hercules-password = {
    neededForUsers = true;
  };

  sops.secrets.hercules-env-vars = {
    owner = "james";
    path = "/var/lib/env_vars";
  };

  # == Yubikey Security - https://nixos.wiki/wiki/Yubikey ==
  security.pam.yubico = {
    enable = true;
    debug = true;
    control = "required";
    mode = "challenge-response";
    id = [
      "19649094"
      "19649058"
    ];
  };
  services.pcscd.enable = true;

  # Uncomment this to lock the screen when the YubiKey is removed
  # services.udev.extraRules = ''
  #   ACTION=="remove",\
  #   ENV{ID_BUS}=="usb",\
  #   ENV{ID_MODEL_ID}=="0407",\
  #   ENV{ID_VENDOR_ID}=="1050",\
  #   ENV{ID_VENDOR}=="Yubico",\
  #   RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  # '';

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

  # == Audio ==
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # == Fixes ==
  services.fprintd.enable = pkgs.lib.mkForce false; # fprintd seems broken atm, and I don't use it (it is being set by the hardware module)
}
