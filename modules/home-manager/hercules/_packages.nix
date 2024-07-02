{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # == Development ==
      blockbench
      deno
      jetbrains-toolbox
      nil
      sculk
      vscode
      warp-terminal

      # == Productivity ==
      _1password-gui
      google-chrome
      obsidian
      okular
      yubioath-flutter

      # == Social ==
      discord
      spotify

      # == Gaming ==
      obs-studio
      prismlauncher
      steam

      # == Maker ==
      candle
      flashprint

      # == SDR ==
      audacity
      gpredict
      noaa-apt
      sdrpp
    ];
  };
}
