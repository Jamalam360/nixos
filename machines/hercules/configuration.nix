{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-configuration.nix

    ./../../modules/nixos/base.nix
  ];

  nixpkgs.overlays = [
    inputs.sculk.overlay
  ];

  # == System Configuration ==
  boot.loader.grub.enable = true;
  networking.hostName = "hercules";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";

  # == Home Manager ==
  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      james = {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/hercules/_packages.nix
        ];
      };
    };
  };

  # == Secrets ==
  sops = pkgs.lib.mkMerge (map (secret: {
      secrets.${secret} = {
        neededForUsers = true;
      };
    }) [
      "hercules-password"
    ]);

  # == Flatpak ==
  services.flatpak.enable = true;
}
