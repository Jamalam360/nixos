{
  config,
  lib,
  pkgs,
  ...
}: let
  userAndGroup = "sat-bot";
  workingDir = "/var/lib/sat-bot";
in {
  sops.secrets = {
    sat-bot-discord-token.neededForUsers = true;
    sat-bot-guild-id.neededForUsers = true;
    sat-bot-n2yo-key.neededForUsers = true;
  };

  environment.systemPackages = [pkgs.custom.sat-bot];

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

  systemd.services.sat-bot = {
    description = "Sat Bot";
    wantedBy = ["multi-user.target"];
    script = ''
      export DISCORD_TOKEN=$(cat "${config.sops.secrets.sat-bot-discord-token.path}");
      export DATABASE_PATH="${workingDir}/sat-bot.json";
      export GUILD_ID=$(cat "${config.sops.secrets.sat-bot-guild-id.path}");
      export N2YO_KEY=$(cat "${config.sops.secrets.sat-bot-n2yo-key.path}");
      ${lib.getExe pkgs.custom.sat-bot}
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
