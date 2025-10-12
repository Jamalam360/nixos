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
  sops.secrets.discord-github-releases-webhook.neededForUsers = true;

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

  networking.firewall.allowedTCPPorts = [port];

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
    script = ''
      DISCORD_WEBHOOK_URL=$(cat ${cconfig.sops.secrets.discord-github-releases-webhook.path}) ${lib.getExe pkgs.custom.discord-github-releases} ${configLocation}
    '';

    serviceConfig = {
      user = userAndGroup;
      group = userAndGroup;

      WorkingDirectory = workingDir;
      SuccessExitStatus = 0;
      TimeoutStopSec = 10;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
