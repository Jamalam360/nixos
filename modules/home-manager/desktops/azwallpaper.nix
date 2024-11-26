{...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "azwallpaper@azwallpaper.gitlab.com"
      ];
    };

    "org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "/home/james/Documents/wallpapers";
    };
  };
}