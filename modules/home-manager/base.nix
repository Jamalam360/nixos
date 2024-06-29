{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./shared/_packages.nix
  ];

  home = {
    username = "james";
    homeDirectory = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "/home/james")
    ];
    stateVersion = "23.11";
  };

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
    };

    gpg.enable = true;
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
