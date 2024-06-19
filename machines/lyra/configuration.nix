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
  networking.networkmanager.enable = true;
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
    ]);

  # == Restic ==
  services.restic.backups.remote.paths = [
    "${config.services.reposilite.dataDir}/reposilite.db"
    "${config.services.reposilite.dataDir}/repositories"
    # TODO: backup Minecraft
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

  # == Minecraft ==
  services.minecraft-servers = let
    modpack = inputs.sculk.nixFunctions.fetchSculkModpack { inherit (pkgs) stdenvNoCC sculk jre_headless; } {
      url = "https://raw.githubusercontent.com/Jamalam360/pack/e1546639bec2a8500e28bc5e4d848d1ee76fad88";
      hash = "sha256-CGkx1IfGpSAK6UdzKGCkU0bGojLBaIVc8/eAkA4zv3Q=";
    };

    # inspo: https://github.com/Infinidoge/nix-minecraft/pull/43
    collectFiles = let
      inherit (pkgs) lib;
      mapListToAttrs = fn: fv: list:
        lib.listToAttrs (map (x: lib.nameValuePair (fn x) (fv x)) list);
    in
      path: prefix:
        mapListToAttrs
        (x: builtins.unsafeDiscardStringContext (lib.removePrefix "${path}/" x))
        (lib.id) (lib.filesystem.listFilesRecursive "${path}/${prefix}");
  in {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/var/lib/minecraft-servers";

    servers.minecraft-server = {
      enable = true;
      package = pkgs.minecraftServers.fabric-1_20_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        "mods" = "${modpack}/mods";
      };
      files = collectFiles "${modpack}" "config" // {
        "config/Discord-Integration.toml" = "/var/lib/Discord-Integration.toml";
      };
      serverProperties = {
        server-port = 25565;
        white-list = true;
      };
      jvmOpts = "-Xmx8G -Xms8G";
    };
  };
  networking.firewall.allowedUDPPorts = [24454]; # Simple Voice Chat mod

  # == Reposilite ==
  services.reposilite = {
    enable = true;
    package = pkgs.callPackage ../../custom/reposilite.nix {};
    settings = {
      port = 8084;
    };
  };

  # == Sat Bot ==
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
