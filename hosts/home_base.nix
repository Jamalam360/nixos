{
  lib,
  pkgs,
  ...
}: {
  home = {
    username = "james";
    homeDirectory = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "/home/james")
    ];
    stateVersion = "23.11";
  };

  home.packages = with pkgs; [
    # development
    just
    sops
    nix-prefetch-github

    # quality of life
    croc
    unzip
    wget
  ];

  programs = {
    git = {
      enable = true;
      delta = {
        enable = true;
      };
      userName = "Jamalam";
      userEmail = "james@jamalam.tech";
      aliases = {
        cp = "cherry-pick";
      };
      signing = {
        key = "B1B22BA0FC39D4B422405F55D86CD68E8DB2E368";
        signByDefault = true;
      };
      extraConfig.pull.rebase = "true";
    };

    gpg.enable = true;
    zoxide.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    bash = {
      enable = true;
      shellAliases = {
        lyra = "ssh james@176.9.22.221";
      };
      initExtra = ''
        export PATH="$PATH:/home/james/.local/share/JetBrains/Toolbox/scripts"
        source /var/lib/env_vars
      '';
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
