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
    ./disk-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../services/lyra/sat-bot.nix
  ];

  boot.loader.grub.enable = true;

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

  networking.hostName = "lyra";
  networking.networkmanager.enable = true;

  sops.secrets.lyra-password.neededForUsers = true;
  sops.secrets.lyra-password = {};
  sops.secrets.sat-bot-discord-token.neededForUsers = true;
  sops.secrets.sat-bot-discord-token = {};
  sops.secrets.sat-bot-guild-id.neededForUsers = true;
  sops.secrets.sat-bot-guild-id = {};
  sops.secrets.sat-bot-n2yo-key.neededForUsers = true;
  sops.secrets.sat-bot-n2yo-key = {};

  services.sat-bot = {
    enable = true;
    package = pkgs.callPackage ./../../custom/sat-bot.nix {};
    settings = {
      discordToken = config.sops.secrets.sat-bot-discord-token.path;
      guildId = config.sops.secrets.sat-bot-guild-id.path;
      n2yoKey = config.sops.secrets.sat-bot-n2yo-key.path;
    };
  };
}
