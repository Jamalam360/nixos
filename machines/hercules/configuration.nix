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
    ./../../modules/nixos/audio.nix
    ./../../modules/nixos/desktop_environment.nix
    ./../../modules/nixos/overlays.nix
    ./../../modules/nixos/virtualisation.nix
  ];

  # == System Configuration ==
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hercules";
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
    hercules-password = {
      neededForUsers = true;
    };

    desktops-env-vars = {
      owner = "james";
      path = "/var/lib/env_vars";
    };
  };

  # == Yubikey Security - https://nixos.wiki/wiki/Yubikey ==
  security.pam.yubico = {
    enable = true;
    debug = false;
    control = "required";
    mode = "challenge-response";
    id = [
      "19649094"
      "19649058"
    ];
  };
  services.pcscd.enable = true;

  # Lock screen when yubikey is removed
  # services.udev.extraRules = ''
  #     ACTION=="remove",\
  #      ENV{ID_BUS}=="usb",\
  #      ENV{ID_MODEL_ID}=="0407",\
  #      ENV{ID_VENDOR_ID}=="1050",\
  #      ENV{ID_VENDOR}=="Yubico",\
  #      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  # '';

  # == Stylix ==
  stylix.enable = true;
  stylix.image = ../../wallpapers/alpine.jpeg;
  stylix.polarity = "dark";
  stylix.fonts = {
    serif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };

    sansSerif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };

    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };

    emoji = {
      package = pkgs.twitter-color-emoji;
      name = "Twitter Color Emoji";
    };
  };

  # == Fixes ==
  services.fprintd.enable = pkgs.lib.mkForce false; # fprintd seems broken atm, and I don't use it (it is being set by the hardware module)
}
