{...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "tiling-assistant@leleat-on-github"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "emoji-copy@felipeftn"
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
}
