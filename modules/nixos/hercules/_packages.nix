{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # == Gnome Extensions ==
    gnomeExtensions.tiling-assistant

    # == VMs ==
    spice
    spice-gtk
    spice-protocol
    virt-viewer
  ];
}
