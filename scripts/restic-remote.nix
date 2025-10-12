// inspo: https://github.com/johnae/world/blob/35653ce23a51fa022cc2663d6894da0544547e7d/profiles/restic-helper.nix#L7
{
  pkgs,
  config,
  lib,
  ...
}: let
  restic-pkgs =
    lib.mapAttrsToList (
      name: value:
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
        }
    )
    config.services.restic.backups;
in {
  environment.systemPackages = restic-pkgs;
}
