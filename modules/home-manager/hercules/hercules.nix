{
  ...
}: {
  imports = [
    ./_packages.nix
    ./jdks.nix
  ];

  programs = {
    bat.enable = true;
    zoxide.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        cat = "bat";
        lyra = "ssh james@176.9.22.221";
      };
      initExtra = ''
        export PATH="$PATH:/home/james/.local/share/JetBrains/Toolbox/scripts"
        source /var/lib/env_vars
      '';
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/zip" = "org.gnome.Nautilus.desktop";
    };
  };
}
