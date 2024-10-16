{pkgs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  console.useXkbConfig = true;
  services.printing.enable = true;
  hardware.graphics.enable32Bit = true; # fixes an issue with steam

  environment.systemPackages = with pkgs; [
    gnomeExtensions.tiling-assistant
    gnomeExtensions.emoji-copy
    gnome-tweaks
  ];
}
