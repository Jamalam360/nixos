{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Packages that cannot be managed via devshells or that I want globally
    # == Development ==
    aseprite
    blockbench
    insomnia
    jetbrains-toolbox
    inputs.sculk.packages.x86_64-linux.sculk
    unityhub
    vscode
    warp-terminal

    # == Productivity ==
    _1password-gui
    eyedropper
    google-chrome
    kdePackages.kdenlive
    obsidian
    okular # pdf reader
    oxipng
    pinentry-gnome3
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

    # == VMs ==
    gnome-boxes
  ];
}
