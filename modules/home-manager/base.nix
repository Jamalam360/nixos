{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
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
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
