{
  inputs,
  outputs,
  pkgs,
  config,
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

  users.users.james.extraGroups = [ "docker" "libvirtd" ];

  # == Secrets ==
  sops.secrets.hercules-password = {
    neededForUsers = true;
  };

  sops.secrets.desktops-env-vars = {
    owner = "james";
    path = "/var/lib/env_vars";
  };

  sops.secrets.university-vpn-password = {
    neededForUsers = true;
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

  # == Docker ==
  virtualisation.docker.enable = true;

  # == VMs ==
  # inspo: https://github.com/erictossell/nixflakes/blob/main/modules/virt/libvirt.nix
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  home-manager.users.james = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };

  # == University VPN ==
  # TODO: set up university NetworkManager VPN declaratively

  # == Fixes ==
  services.fprintd.enable = pkgs.lib.mkForce false; # fprintd seems broken atm, and I don't use it (it is being set by the hardware module)
  hardware.graphics.enable32Bit = true; # fixes an issue with steam
}
