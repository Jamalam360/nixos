{pkgs, ...}: {
  imports = [
    ./audio.nix
    ./stylix.nix
    ./ld.nix
  ];

  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
  };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  console.useXkbConfig = true;
  services.printing.enable = true;
  hardware.graphics.enable32Bit = true; # fixes an issue with steam
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.emoji-copy
    gnomeExtensions.tiling-assistant
    gnome-tweaks
  ];
}
