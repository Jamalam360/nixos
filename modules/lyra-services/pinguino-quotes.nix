{
  config,
  lib,
  pkgs,
  ...
}: let
  userAndGroup = "pinguino-quotes";
  workingDir = "/var/lib/pinguino-quotes";
in {
  sops.secrets.pinguino-quotes-discord-token.neededForUsers = true;

  services.restic.backups.remote.paths = [
    "${workingDir}/pinguino-quotes.db"
  ];

  environment = {
    systemPackages = [pkgs.custom.pinguino-quotes];
    etc."pinguino-quotes/config.yaml".text = builtins.toJSON {
      database = {
        database_path = "${workingDir}/pinguino-quotes.db";
      };
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

  systemd.services.pinguino-quotes = {
    description = "Pinguino Quotes";
    wantedBy = ["multi-user.target"];
    script = ''
      export DISCORD_TOKEN=$(cat "${config.sops.secrets.pinguino-quotes-discord-token.path}");
      export CONFIG_PATH="/etc/pinguino-quotes/config.yaml";
      ${lib.getExe pkgs.custom.pinguino-quotes}
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
