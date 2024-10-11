{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # == Gnome Extensions ==
    gnomeExtensions.tiling-assistant

    gnome.gnome-tweaks
  ];
}
