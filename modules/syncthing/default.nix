{
  config,
  pkgs,
  lib,
  ...
}: let
  host = config.networking.hostName;
  deviceIds = {
    ara = "4RQ4DHV-6B256XO-EWNDCAK-PXX6EL3-AOWLLRB-T63Q4WO-WI6AMQI-H7Q4BA3";
    hercules = "B6X33YJ-F2OVMOE-76C4273-JBFDUR3-QFFN7FR-6JOYUGE-GJU2MDW-3OZ6AQR";
    leo = "ZTCJYKH-ZJDXFAW-COANVNR-CNMD4E7-KO74IWE-PIC72R2-CAQ3T2T-V5KGJAI";
    phone = "VDCHIDO-MPK6XCP-SNBRUYH-MOFH7JF-UG6A2QU-J4SWTZK-ZFPKEA7-LG5K5QL";
  };
  owner = config.services.syncthing.user;
in {
  sops.secrets = {
    syncthing-password = {
      inherit owner;
      restartUnits = ["syncthing-init.service"];
    };
    "${host}-syncthing-key" = {
      inherit owner;
      restartUnits = ["syncthing.service"];
    };
    "${host}-syncthing-cert" = {
      inherit owner;
      restartUnits = ["syncthing.service"];
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  services.syncthing = {
    enable = true;
    user = "james";
    group = "users";
    dataDir = "/home/james";
    configDir = "/home/james/.config/syncthing";
    openDefaultPorts = true;
    key = config.sops.secrets."${host}-syncthing-key".path;
    cert = config.sops.secrets."${host}-syncthing-cert".path;
    guiPasswordFile = config.sops.secrets.syncthing-password.path;
    settings = {
      gui.user = "james";
      devices = builtins.mapAttrs (_: id: {inherit id;}) deviceIds;
      folders."personal-knowledge-base" = {
        label = "Personal Knowledge Base";
        path = "/home/james/Documents/Sync/Personal Knowledge Base";
        devices = builtins.attrNames deviceIds;
      };
    };
  };
}
