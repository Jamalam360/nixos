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
  };

  users.mutableUsers = false;
  users.users.james = {
    isNormalUser = true;
    description = "james";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhtjY3U8EsdEmrwbYJQQNwNqQHinZp1kQLqF7wdUkXI"
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets."${config.networking.hostName}-password".path;
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
