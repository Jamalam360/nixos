{
  config,
  lib,
  pkgs,
  ...
}: let
  port = 8072;
  userAndGroup = "discord-github-releases";
  workingDir = "/var/lib/discord-github-releases";
in {
  sops.secrets.discord-github-releases-webhook = {
    restartUnits = ["discord-github-releases.service"];
  };

  environment = {
    systemPackages = [pkgs.custom.discord-github-releases];
    etc."discord-github-releases/config.json".text = builtins.toJSON {
      inherit port;

      discord_webhook_urls = [
        "$DISCORD_WEBHOOK_URL"
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

  services.nginx.virtualHosts."discord-github-releases.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
    };
  };

  users = {
    groups.${userAndGroup} = {
      name = userAndGroup;
    };

    users.${userAndGroup} = {
      group = userAndGroup;
      home = workingDir;
      isSystemUser = true;
      createHome = true;
    };
  };

  systemd.services.discord-github-releases = let
    configLocation = "/etc/discord-github-releases/config.json";
  in {
    description = "Discord GitHub Releases";
    wantedBy = ["multi-user.target"];
    onFailure = ["notify-failure@%n.service"];
    script = ''
      DISCORD_WEBHOOK_URL=$(cat $CREDENTIALS_DIRECTORY/webhook) ${lib.getExe pkgs.custom.discord-github-releases} ${configLocation}
    '';

    serviceConfig = {
      LoadCredential = "webhook:${config.sops.secrets.discord-github-releases-webhook.path}";
      User = userAndGroup;
      Group = userAndGroup;
      WorkingDirectory = workingDir;
      SuccessExitStatus = 0;
      TimeoutStopSec = 10;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
