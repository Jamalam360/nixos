{pkgs, ...}: {
  imports = [
    ./audio.nix
    ./stylix.nix
    ./ld.nix
  ];

  console.useXkbConfig = true;
  hardware.graphics.enable32Bit = true; # fixes an issue with steam
  systemd.tmpfiles.rules = [ "e /home/james/Downloads - - - 3d" ]; # delete downloads older than 3 days

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    pcscd.enable = true;
    gnome.evolution-data-server.enable = pkgs.lib.mkForce false;

    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        (hplip.override {withPlugin = true;})
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      gnomeExtensions.colorblind-filters
      gnomeExtensions.emoji-copy
      gnomeExtensions.tiling-assistant
      gnome-tweaks
    ];

    gnome.excludePackages = with pkgs; [
      decibels
      epiphany
      gnome-calendar
      gnome-clocks
      gnome-contacts
      gnome-logs
      gnome-maps
      gnome-music
      gnome-tecla
      gnome-weather
      gnome-connections
      simple-scan
      yelp
    ];
  };
}
