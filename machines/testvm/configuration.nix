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

    ./../../services/reposilite.nix
    ./../../services/discord-github-releases.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      james = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  sops.secrets.testvm-password.neededForUsers = true;
  sops.secrets.testvm-password = {};
  sops.secrets.test-discord-webhook-url.neededForUsers = true;
  sops.secrets.test-discord-webhook-url = {};

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "testvm";

  services.reposilite = {
    enable = true;
    package = import ../../custom/reposilite.nix { inherit (pkgs) stdenv lib makeWrapper openjdk17_headless; };
    settings = {
      port = 8084;
    };
  };

  services.discord-github-releases = {
    enable = true;
    package = import ../../custom/discord-github-releases.nix { inherit (pkgs) stdenv lib makeWrapper deno fetchFromGitHub; };
    settings = {
      discord_webhook_urls = [
        config.sops.secrets.test-discord-webhook-url
      ];
      port = 8085;
      message = {
        content = "Test!";
      };
    };
  };
}

