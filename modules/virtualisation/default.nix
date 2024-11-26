{
  pkgs,
  ...
}: {
  # inspo: https://github.com/erictossell/nixflakes/blob/main/modules/virt/libvirt.nix
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;

    # == Docker ==
    docker.enable = true;
  };

  programs.virt-manager.enable = true;
  users.users.james.extraGroups = ["docker" "libvirtd"];

  home-manager.users.james = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}