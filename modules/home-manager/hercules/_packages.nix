{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # == Development ==
      pkgs.deno
      pkgs.jetbrains-toolbox
      pkgs.nil
      pkgs.sculk
      pkgs.vscode
      pkgs.warp-terminal

      # == Productivity ==
      pkgs._1password-gui
      pkgs.google-chrome
      pkgs.obsidian
      pkgs.okular
      pkgs.yubioath-flutter

      # == Social ==
      pkgs.discord
      pkgs.spotify

      # == Gaming ==
      pkgs.obs-studio
      pkgs.prismlauncher
      pkgs.steam

      # == Maker ==
      pkgs.candle
      pkgs.flashprint

      # == SDR ==
      pkgs.audacity
      pkgs.gpredict
      pkgs.noaa-apt
      pkgs.sdrpp
    ];
  };
}
