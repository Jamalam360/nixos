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
    ./../../services/orion/sat-bot.nix
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
  sops.secrets.sat-bot-discord-token.neededForUsers = true;
  sops.secrets.sat-bot-discord-token = {};
  sops.secrets.sat-bot-guild-id.neededForUsers = true;
  sops.secrets.sat-bot-guild-id = {};
  sops.secrets.sat-bot-n2yo-key.neededForUsers = true;
  sops.secrets.sat-bot-n2yo-key = {};

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "testvm";

  # services.reposilite = {
  #   enable = true;
  #   package = import ../../custom/reposilite.nix { inherit (pkgs) stdenv lib makeWrapper openjdk17_headless; };
  #   settings = {
  #     port = 8084;
  #   };
  # };

  # services.discord-github-releases = {
  #   enable = true;
  #   package = import ../../custom/discord-github-releases.nix { inherit (pkgs) stdenv lib makeWrapper deno fetchFromGitHub; };
  #   settings = {
  #     discord_webhook_urls = [
  #       config.sops.secrets.test-discord-webhook-url.path
  #     ];
  #     port = 8085;
  #     message = {
  #       content = "Test!";
  #     };
  #   };
  # };

  services.sat-bot = {
    enable = true;
    package = import ../../custom/sat-bot.nix { inherit (pkgs) lib fetchFromGitHub rustPlatform openssl pkg-config; };
    settings = {
      discordToken = config.sops.secrets.sat-bot-discord-token.path;
      guildId = config.sops.secrets.sat-bot-guild-id.path;
      n2yoKey = config.sops.secrets.sat-bot-n2yo-key.path;
    };
  };
}
