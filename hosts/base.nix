{
  inputs,
  config,
  pkgs,
  ...
}: let
  root = ./..;
  substituters = [
    "http://nixcache.jamalam.tech"
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
        "electron-19.1.9"
      ];
    };

    overlays = [
      (import /.${root}/overlays {inherit inputs;})
    ];
  };

  nix = {
    settings = {
      inherit substituters;

      always-allow-substitutes = true;
      accept-flake-config = true;
      auto-optimise-store = true;
      download-buffer-size = 268435456; # 4x default
      experimental-features = "nix-command flakes";
      max-jobs = "auto";
      min-free = 1073741824; # 1GiB
      trusted-users = ["james"];

      # Ensure builds can still complete if one of the substituters is down
      fallback = true;
      connect-timeout = 3;

      trusted-substituters = substituters;
      trusted-public-keys = [
        "nixcache.jamalam.tech:kK0ZbqNEnH1UMq3LJk8EDsLbI1H2K8ooQAqiiU7/5s0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  sops = {
    defaultSopsFile = /.${root}/secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.env-vars = {
      owner = "james";
      path = "/var/lib/env_vars";
    };
  };

  users.mutableUsers = true;
  users.users.james = {
    isNormalUser = true;
    description = "james";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhtjY3U8EsdEmrwbYJQQNwNqQHinZp1kQLqF7wdUkXI"
    ];
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."${config.networking.hostName}-password".path;
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    git
    gnupg
    gptfdisk
    oxipng
    parted
  ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };

    fstrim.enable = true;
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  # inspo: https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
