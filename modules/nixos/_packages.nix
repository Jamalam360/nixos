{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    efibootmgr
    fastfetch
    git
    gptfdisk
    parted
    vim
  ];
}
