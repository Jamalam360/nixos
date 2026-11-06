{
  config,
  pkgs,
  lib,
  ...
}: let
  allDevices = ["hercules" "leo" "ara" "phone"];
  device = (id: {
    id = id;
  });
in {
  sops.secrets.syncthing-password.neededForUsers = true;
  sops.secrets.syncthing-key.neededForUsers = true;
  sops.secrets.syncthing-cert.neededForUsers = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    extraFlags = [ "--no-default-folder" ];
    key = config.sops.secrets.syncthing-cert.path;
    cert = config.sops.secrets.syncthing-key.path;
    guiPasswordFile = config.sops.secrets.syncthing-password.path;
    settings = {
      gui.user = "james";
      devices = (map device allDevices);
      folders = {
        "pkb" = {
          label = "Personal Knowledge Base";
          path = "/home/james/Documents/Sync/Personal Knowledge Base";
          devices = allDevices;
        }
      };
    };
  };
}
