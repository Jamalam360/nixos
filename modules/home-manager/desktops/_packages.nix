{pkgs, ...}: {
  home.packages = with pkgs; [
    # Packages that cannot be managed via devshells or that I want globally
    # == Development ==
    aseprite
    blockbench
    insomnia
    jetbrains-toolbox
    sculk
    unityhub
    vscode
    warp-terminal

    # == Productivity ==
    _1password-gui
    eyedropper
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

    # == VMs ==
    gnome-boxes
  ];
}
