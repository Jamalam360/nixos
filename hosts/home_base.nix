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
    btop
    croc
    unzip
    wget
  ];

  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Jamalam";
          email = "james@jamalam.tech";
        };
        aliases = {
          cp = "cherry-pick";
        };
        pull.rebase = "true";
      };

      signing = {
        key = "B1B22BA0FC39D4B422405F55D86CD68E8DB2E368";
        signByDefault = true;
      };
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
        ara = "ssh james@46.62.221.196";
      };
      initExtra = ''
        export PATH="$PATH:/home/james/.local/share/JetBrains/Toolbox/scripts"
        source /var/lib/env_vars
        # Not sure how OK this is...
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      '';
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };
}
