{pkgs, ...}: let
  copy-artifacts-to-prism = pkgs.writeShellScriptBin "copy-artifacts-to-prism" (import ././../../../scripts/copy-artifacts-to-prism.nix);
in {
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
    flashprint # 3D printing

    # == SDR ==
    audacity
    gpredict
    noaa-apt
    sdrpp

    # == VMs ==
    gnome-boxes

    # == Scripts ==
    copy-artifacts-to-prism
  ];
}
