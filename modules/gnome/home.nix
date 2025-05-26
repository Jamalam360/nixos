{pkgs, ...}: {
  imports = [
    ./spotify.nix
    ./vscode.nix
  ];

  programs.bat.enable = true;
  programs.bash.shellAliases = {
    cat = "bat";
    cd = "z";
    # Fixes some Minecraft mod dev bugs
    gradlew = "LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH\" __GL_THREADED_OPTIMIZATIONS=0 ./gradlew";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "org.gnome.gedit.desktop";
      "application/json" = "org.gnome.gedit.desktop";
      "application/zip" = "org.gnome.Nautilus.desktop";
      "video/mp4" = "org.gnome.Totem.desktop";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      natural-scroll = false;
      speed = 0.5;
    };

    "org/gnome/desktop/session" = {
      idle-delay = 0;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      power-button-action = "interactive";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "emoji-copy@felipeftn"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "tiling-assistant@leleat-on-github"
      ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
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
    ghostty
    gnome-boxes
    google-chrome
    gpredict
    insomnia
    jetbrains-toolbox
    kdePackages.kdenlive
    noaa-apt
    obs-studio
    obsidian
    pinentry-gnome3
    prismlauncher
    sdrpp
    steam
    ticktick
    warp-terminal
    wireshark
    yubioath-flutter # yubico authenticator

    # == Scripts ==
    scripts.copy-artifacts-to-prism
    scripts.devshell-init
  ];
}
