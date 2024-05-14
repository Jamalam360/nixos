{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops

    ./_packages.nix
  ];

  # FIXME: this needs moving to the specific config files for machines
  # boot.loader = {
  #   systemd-boot = {
  #     enable = true;
  #     configurationLimit = 5;
  #   };
  #   efi.canTouchEfiVariables = true;
  #   timeout = 10;
  # };

  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.user-password.neededForUsers = true;
    # TODO: make this password unique per machine
    secrets.user-password = {};
  };

  users.mutableUsers = false;
  users.users.james = {
    isNormalUser = true;
    description = "james";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      # TODO: replace with my key. Also add my key to 1password
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkcgwjYMHqUDnx0JIOSXQ/TN80KEaFvvUWA2qH1AHFC"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.user-password.path;
  };

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

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/London";

  # environment.persistence."/nix/persist" = {
  #   # Hide these mounts from the sidebar of file managers
  #   hideMounts = true;

  #   directories = [
  #     "/var/log"
  #   ];

  #   files = [
  #     "/etc/machine-id"
  #     "/etc/ssh/ssh_host_ed25519_key.pub"
  #     "/etc/ssh/ssh_host_ed25519_key"
  #     "/etc/ssh/ssh_host_rsa_key.pub"
  #     "/etc/ssh/ssh_host_rsa_key"
  #   ];
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
