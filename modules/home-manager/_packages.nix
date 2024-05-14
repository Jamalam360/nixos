{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # fun
      fastfetch

      # development
      just
      sops

      # quality of life
      croc
    ];
  };
}
