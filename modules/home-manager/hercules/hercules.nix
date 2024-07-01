{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
  ];

  programs = {
    bat.enable = true;
    zoxide.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        cat = "bat";
      };
      initExtra = ''
        export PATH="$PATH:/home/james/.local/share/JetBrains/Toolbox/scripts"
        source /var/lib/env_vars
      '';
    };
  };
}
