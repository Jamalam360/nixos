{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnomeExtensions.tiling-assistant
  ];
}
