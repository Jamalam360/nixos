{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: let
  fetchSculkModpack = pkgs.callPackage ../../custom/sculk-modpack.nix {};
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-minecraft.nixosModules.minecraft-servers

    ./hardware-configuration.nix
    ./disk-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../services/lyra/discord-github-releases.nix
    ./../../services/lyra/nginx.nix
    ./../../services/lyra/reposilite.nix
    ./../../services/lyra/restic.nix
    ./../../services/lyra/sat-bot.nix
    ./../../services/lyra/static/cdn.nix
    ./../../services/lyra/static/its-clearing-up.nix
    ./../../services/lyra/static/teach-man-fish.nix
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
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
  time.timeZone = "Europe/Berlin";

  sops = pkgs.lib.mkMerge (map (secret: {
      secrets.${secret} = {
        neededForUsers = true;
      };
    }) [
      "lyra-password"
      "restic-remote-env"
      "restic-remote-password"
      "discord-github-releases-webhook"
      "sat-bot-discord-token"
      "sat-bot-guild-id"
      "sat-bot-n2yo-key"
    ]);

  # https://nixos.wiki/wiki/Binary_Cache
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-private-key.pem";
  };

  services.restic.backups.remote.paths = [
    "${config.services.reposilite.dataDir}/reposilite.db"
    "${config.services.reposilite.dataDir}/repositories"
  ];

  services.nginx.virtualHosts."nixcache.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
  };

  services.discord-github-releases = {
    enable = true;
    package = pkgs.callPackage ../../custom/discord-github-releases.nix {};
    openFirewall = true;
    settings = {
      port = 8072;

      discord_webhook_urls = [
        config.sops.secrets.discord-github-releases-webhook.path
      ];

      message = {
        username = "Release Watcher";
        avatar_url = "https://github.com/JamCoreModding.png";
        embeds = [
          {
            title = "An update has been released for $repo_name";
            url = "$release_url";
            description = "$release_body";

            fields = [
              {
                name = "Name";
                value = "$release_name";
              }
              {
                name = "Tag";
                value = "$release_tag_name";
              }
            ];

            author = {
              name = "$author_name";
              url = "$author_profile_url";
              icon_url = "$author_avatar_url";
            };
          }
        ];
      };
    };
  };

  services.minecraft-servers.servers.minecraft-server = let
    modpack = fetchSculkModpack {
      modpackOwner = "Jamalam360";
      modpackRepo = "pack";
      modpackRev = "74946b6c726204769120cffab8ee6ca46ccad262";
      modpackHash = pkgs.lib.fakeSha256;
      derivationHash = pkgs.lib.fakeSha256;
    };
  in {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/var/lib/minecraft-servers";

    servers.personal-mc-server = {
      enable = true;
      package = pkgs.minecraftServers.fabric-1_20_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        "mods" = "${modpack}/mods";
        "config" = "${modpack}/config";
      };
      serverProperties = {
        server-port = 25565;
        white-list = true;
      };
      jvmOpts = "-Xmx8G -Xms8G";
    };
  };

  services.reposilite = {
    enable = true;
    package = pkgs.callPackage ../../custom/reposilite.nix {};
    settings = {
      port = 8084;
    };
  };

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
