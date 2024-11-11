{...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "azwallpaper@azwallpaper.gitlab.com"
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
      idle-delay = "uint32 0";
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
    "/org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "/home/james/Documents/wallpapers";
    };
  };

  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/james/dev dev
    file:///home/james/dev/minecraft minecraft
  '';
}
