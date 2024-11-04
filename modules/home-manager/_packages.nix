{pkgs, ...}: {
  home.packages = with pkgs; [
    # fun
    fastfetch

    # development
    just
    sops
    nix-prefetch-github

    # quality of life
    croc
    csvlens
    unzip
    wget
  ];
}
