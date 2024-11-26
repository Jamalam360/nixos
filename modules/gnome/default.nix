{
  pkgs,
  ...
}: {
  imports = [
    ./audio.nix
    ./stylix.nix
  ];

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
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.emoji-copy
    gnomeExtensions.tiling-assistant
    gnome-tweaks
  ];
}