{
  config,
  pkgs,
  lib,
  ...
}: {
  services.syncthing.settings.folders."personal-knowledge-base".versioning = {
    type = "staggered";
    params = {
      maxAge = toString (30 * 24 * 60 * 60);
      cleanInterval = "3600";
    };
  };

  services.restic.backups.remote = let
    vault = "/home/james/Documents/Sync/Personal Knowledge Base";
  in {
    path = [vault];
    exclude = ["${vault}/.stversions"];
  };
}
