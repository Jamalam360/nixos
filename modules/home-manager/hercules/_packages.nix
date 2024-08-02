{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # == Development ==
      aseprite
      blockbench
      cargo
      deno
      dotnet-sdk_8
      jetbrains-toolbox
      nil # nix language server
      nodejs_22
      nodePackages.pnpm
      sculk
      unityhub
      vscode
      warp-terminal

      # == Productivity ==
      _1password-gui
      google-chrome
      obsidian
      okular # pdf reader
      oxipng
      shotcut
      yubioath-flutter # yubico authenticator

      # == Social ==
      discord
      spotify

      # == Gaming ==
      obs-studio
      prismlauncher
      steam

      # == Maker ==
      candle # CNC
      flashprint

      # == SDR ==
      audacity
      gpredict
      noaa-apt
      sdrpp
    ];
  };
}
