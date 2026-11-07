{
  lib,
  pkgs,
  ...
}: let
  userAndGroup = "reposilite";
  workingDir = "/var/lib/reposilite";
  dbDump = "${workingDir}/backup/reposilite.db";
  generateConfig = config:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}: ${
        (
          if (lib.isBool value)
          then (lib.boolToString value)
          else (toString value)
        )
      }")
      config);
in {
  services.restic.backups.remote.paths = [
    dbDump
    "${workingDir}/repositories"
  ];

  # Take a dump of the DB in case it changes mid-backup
  systemd.services.restic-backups-remote.preStart = ''
    if [ -f "${workingDir}/reposilite.db" ]; then
      mkdir -p "$(dirname ${dbDump})"
      ${lib.getExe pkgs.sqlite} -bail "${workingDir}/reposilite.db" ".backup '${dbDump}'"
    fi
  '';

  environment = {
    systemPackages = [pkgs.reposilite];
    etc."reposilite/configuration.cdn".text = generateConfig {
      port = 8084;
    };
  };

  services.nginx.virtualHosts."maven.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8084/";
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

  systemd.services.reposilite = {
    description = "Reposilite";
    wantedBy = ["multi-user.target"];
    onFailure = ["notify-failure@%n.service"];
    script = ''
      ${lib.getExe pkgs.reposilite} --working-directory "${workingDir}" --local-config "/etc/reposilite/configuration.cdn" --local-configuration-mode auto
    '';

    serviceConfig = {
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
