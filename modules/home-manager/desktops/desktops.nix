{...}: {
  imports = [
    ./_packages.nix
    ./desktop_environment.nix
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

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "org.gnome.gedit.desktop";
      "text/json" = "org.gnome.gedit.desktop";
      "application/zip" = "org.gnome.Nautilus.desktop";
    };
  };
}
