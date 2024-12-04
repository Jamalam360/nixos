{pkgs, ...}: {
  programs.bat.enable = true;
  programs.bash.shellAliases.cat = "bat";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "org.gnome.gedit.desktop";
      "text/json" = "org.gnome.gedit.desktop";
      "application/zip" = "org.gnome.Nautilus.desktop";
      "video/mp4" = "org.gnome.Totem.desktop";
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "emoji-copy@felipeftn"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "tiling-assistant@leleat-on-github"
      ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
      accel-profile = "flat";
      speed = 0.5;
    };
    "org/gnome/desktop/session" = {
      idle-delay = 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
  };

  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/james/dev dev
    file:///home/james/dev/minecraft minecraft
  '';

  home.packages = with pkgs; [
    _1password-gui
    # == Development ==
    aseprite
    audacity
    blockbench
    candle # CNC
    sculk
    discord
    eyedropper
    flashprint # 3D printing
    gnome-boxes
    google-chrome
    gpredict
    insomnia
    jetbrains-toolbox
    kdePackages.kdenlive
    noaa-apt
    obs-studio
    obsidian
    okular # pdf reader
    pinentry-gnome3
    prismlauncher
    sdrpp
    spotify
    steam
    vscode
    warp-terminal
    yubioath-flutter # yubico authenticator

    # == Scripts ==
    scripts.copy-artifacts-to-prism
    scripts.devshell-init
  ];
}
