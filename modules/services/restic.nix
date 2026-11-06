# inspo: https://github.com/johnae/world/blob/670709a36223bc9535b1b2c7bfeeb110ac314f47/profiles/restic-backup.nix#L13
{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets = {
    restic-remote-env.neededForUsers = true;
    restic-remote-password.neededForUsers = true;
  };

  services.restic.backups.remote = {
    initialize = true;
    repository = "s3:s3.us-west-004.backblazeb2.com/jamalam-orion-backup";
    environmentFile = config.sops.secrets.restic-remote-env.path;
    passwordFile = config.sops.secrets.restic-remote-password.path;
    timerConfig = {
      OnCalendar = "*-*-* *:00:00";
      RandomizedDelaySec = "5m";
    };
  };

  systemd.services.restic-prune-remote = let
    backup = config.services.restic.backups.remote;
    keep = [
      "--keep-hourly"
      "48"
      "--keep-daily"
      "30"
      "--keep-weekly"
      "12"
      "--keep-monthly"
      "24"
    ];
  in {
    description = "Forget and prune old restic snapshots";
    wants = ["network-online.target"];
    after = ["network-online.target"];
    environment = {
      RESTIC_REPOSITORY = backup.repository;
      RESTIC_PASSWORD_FILE = backup.passwordFile;
      RESTIC_CACHE_DIR = "/var/cache/restic-backups-remote";
    };
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = backup.environmentFile;
      CacheDirectory = "restic-backups-remote";
      ExecStart = lib.escapeShellArgs (
        ["${pkgs.restic}/bin/restic" "forget" "--prune" "--retry-lock" "2h"] ++ keep
      );
    };
  };

  systemd.timers.restic-prune-remote = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 04:30:00";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };
  };

  # inspo: https://github.com/johnae/world/blob/35653ce23a51fa022cc2663d6894da0544547e7d/profiles/restic-helper.nix#L7
  environment.systemPackages =
    [pkgs.restic]
    ++ lib.mapAttrsToList
    (name: value:
      pkgs.writeShellApplication {
        name = "restic-${name}";
        runtimeInputs = [pkgs.restic];
        text = ''
          while read -r line;
          do
            eval "export $line"
          done < ${value.environmentFile}
          export RESTIC_PASSWORD_FILE=${value.passwordFile}
          export RESTIC_REPOSITORY=${value.repository}

          restic "$@"
        '';
      })
    (lib.attrByPath ["services" "restic" "backups"] {} config);
}
