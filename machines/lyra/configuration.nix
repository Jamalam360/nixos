{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-minecraft.nixosModules.minecraft-servers

    ./hardware-configuration.nix
    ./disk-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../services/lyra/discord-github-releases.nix
    ./../../services/lyra/nginx.nix
    ./../../services/lyra/pinguino-quotes.nix
    ./../../services/lyra/reposilite.nix
    ./../../services/lyra/restic.nix
    ./../../services/lyra/sat-bot.nix
    ./../../services/lyra/static/cdn.nix
    ./../../services/lyra/static/its-clearing-up.nix
    ./../../services/lyra/static/teach-man-fish.nix
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    inputs.sculk.overlay
  ];

  # == System Configuration ==
  boot.loader.grub.enable = true;
  networking.hostName = "lyra";
  time.timeZone = "Europe/Berlin";

  # == Home Manager ==
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

  # == Secrets ==
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
      "pinguino-quotes-discord-token"
    ]);

  # == Restic ==
  services.restic.backups.remote.paths = [
    "/var/lib/pinguino-quotes/pinguino-quotes.db"
    "${config.services.reposilite.dataDir}/reposilite.db"
    "${config.services.reposilite.dataDir}/repositories"
    "/var/lib/minecraft-servers/minecraft-server/DiscordIntegration-Data"
    "/var/lib/minecraft-servers/minecraft-server/ops.json"
    "/var/lib/minecraft-servers/minecraft-server/whitelist.json"
    "/var/lib/minecraft-servers/minecraft-server/audioplayer_uploads"
    "/var/lib/minecraft-servers/minecraft-server/world"
  ];

  # == Nix Cache (https://nixos.wiki/wiki/Binary_Cache) ==
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-private-key.pem";
  };

  services.nginx.virtualHosts."nixcache.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
  };

  # == Discord GitHub Releases ==
  services.discord-github-releases = {
    enable = true;
    package = pkgs.callPackage ../../pkgs/discord-github-releases.nix {};
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

  # == Minecraft ==
  services.minecraft-servers = let
    modded_modpack = inputs.sculk.nixFunctions.fetchSculkModpack {inherit (pkgs) stdenvNoCC sculk jre_headless;} {
      # Updated by CI
      # modded-modpack-version-begin
      url = "https://raw.githubusercontent.com/Jamalam360/pack/75844eefc810b37e13d4a3fa99a60e6114410aef";
      hash = "sha256-mnyDKK+JWRGDL0g00lKYcG7BJB0o2MB3IS3JF4Y363U=";
      # modded-modpack-version-end
    };

    vanilla_modpack = inputs.sculk.nixFunctions.fetchSculkModpack {inherit (pkgs) stdenvNoCC sculk jre_headless;} {
      # Updated by CI
      # vanilla-modpack-version-begin
      url = "https://raw.githubusercontent.com/Jamalam360/vanilla-server/88e198103812722496c9719e0851f9b4f48821a6";
      hash = "sha256-zOakwq82dMu1TsmCwpnMHDkXRu7EkoBXP/DFtj74d08=";
      # vanilla-modpack-version-end
    };
  in {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/var/lib/minecraft-servers";

    servers.minecraft-server = {
      enable = false;
      package = pkgs.minecraftServers.fabric-1_20_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        mods = "${modded_modpack}/mods";
        config = "${modded_modpack}/config";
      };
      files = {
        "config/Discord-Integration.toml" = "/var/lib/Discord-Integration.toml";
      };
      serverProperties = {
        server-port = 25565;
        white-list = true;
        level-seed = 5716240849493836707;
        view-distance = 20;
        difficulty = "hard";
      };
      jvmOpts = "-Xmx6G -Xms6G";
    };

    servers.vanilla-server = {
      enable = true;
      package = pkgs.minecraftServers.fabric-1_21_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        mods = "${vanilla_modpack}/mods";
        config = "${vanilla_modpack}/config";
      };
      serverProperties = {
        server-port = 25566;
        white-list = true;
        view-distance = 20;
        difficulty = "hard";
      };
      jvmOpts = "-Xmx4G -Xms4G";
    };
  };

  networking.firewall.allowedUDPPorts = [24454]; # Simple Voice Chat mod

  systemd.timers."restart-minecraft" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Unit = "restart-minecraft.service";
    };
  };

  systemd.services."restart-minecraft" = {
    script = ''
      set -eu
      systemctl restart minecraft-server-minecraft-server.service
      systemctl restart minecraft-server-vanilla-server.service
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # == Reposilite ==
  services.reposilite = {
    enable = true;
    package = pkgs.reposilite;
    settings = {
      port = 8084;
    };
  };

  # == Sat Bot ==
  services.sat-bot = {
    enable = true;
    package = pkgs.callPackage ./../../pkgs/sat-bot.nix {};
    settings = {
      discordToken = config.sops.secrets.sat-bot-discord-token.path;
      guildId = config.sops.secrets.sat-bot-guild-id.path;
      n2yoKey = config.sops.secrets.sat-bot-n2yo-key.path;
    };
  };

  # == Pinguino Quotes ==
  services.pinguino-quotes = {
    enable = true;
    package = pkgs.callPackage ./../../pkgs/pinguino-quotes.nix {};
    token = config.sops.secrets.pinguino-quotes-discord-token.path;
    settings = {
      database = {
        database_path = "/var/lib/pinguino-quotes/pinguino-quotes.db";
      };
    };
  };
}
