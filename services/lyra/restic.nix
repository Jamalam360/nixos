# inspo: https://github.com/johnae/world/blob/670709a36223bc9535b1b2c7bfeeb110ac314f47/profiles/restic-backup.nix#L13
{ config, ... }:

{
  services.restic.backups = {
    remote = {
      repository = "s3:s3.us-west-004.backblazeb2.com/jamalam-orion-backup";

      # paths = ["/home/james/backup-test.txt"];

      initialize = true;
      environmentFile = config.sops.secrets.restic-remote-env.path;
      passwordFile = config.sops.secrets.restic-remote-password.path;
      timerConfig.OnCalendar = "*-*-* *:00:00";
      timerConfig.RandomizedDelaySec = "5m";
      extraBackupArgs = [
        # "--exclude=\"node_modules/*\"" # Example exclude kept for future reference
      ];
    };
  };
}
