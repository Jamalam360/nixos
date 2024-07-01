{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # == Development ==
      pkgs.vscode
      pkgs.warp-terminal
      pkgs.sculk
      pkgs.jetbrains-toolbox

      # == Java ==
      # pkgs.temurin-bin-17
      pkgs.temurin-bin-21

      # == Productivity ==
      pkgs.google-chrome
      pkgs.obsidian
      pkgs._1password-gui
      pkgs.okular
      pkgs.yubioath-flutter

      # == Social ==
      pkgs.discord
      pkgs.spotify

      # == Gaming ==
      pkgs.prismlauncher
      pkgs.steam
      pkgs.obs-studio

      # == Maker ==
      pkgs.candle
      pkgs.flashprint

      # == SDR ==
      pkgs.audacity
      pkgs.sdrpp
      pkgs.noaa-apt
      pkgs.gpredict
    ];
  };
}
