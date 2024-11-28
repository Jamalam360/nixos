{
  lib,
  pkgs,
  ...
}: let
  userAndGroup = "reposilite";
  workingDir = "/var/lib/reposilite";
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
    "${workingDir}/reposilite.db"
    "${workingDir}/repositories"
  ];

  environment = {
    systemPackages = [pkgs.reposilite];
    etc."reposilite/configuration.cdn".text = generateConfig {
      port = 8084;
    };
  };

  networking.firewall.allowedTCPPorts = [8084];
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
    script = ''
      ${lib.getExe pkgs.reposilite} --working-directory "${workingDir}" --local-config "/etc/reposilite/configuration.cdn" --local-configuration-mode auto
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
