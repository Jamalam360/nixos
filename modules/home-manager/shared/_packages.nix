{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # fun
      fastfetch

      # development
      just
      sops
      nix-prefetch-github
      pinentry-gnome3

      # quality of life
      croc
      unzip
      wget
    ];
  };
}
