{ config, pkgs, ... }:
let 
  reposilite = callPackage ../custom/reposilite.nix { }; 
  cfg = { 
    user = "reposilite"; 
    group = "reposilite"; 
    home = "/var/lib/reposilite"; 
    pkg = reposilite; 
    port = 8084;
  };
in
{
  environment.systemPackages = [
    cfg.pkg
  ];

  users.groups.${cfg.group} = {
    name = cfg.group;
  };

  users.users.${cfg.user} = {
    isSystemUser = true;
    group = cfg.group;
    home = cfg.home;
    createHome = true;
  };

  systemd.services."reposilite" = {
    description = "Reposilite - Maven repository";

    wantedBy = [ "multi-user.target" ];

    script = "${cfg.pkg}/bin/reposilite --working-directory ${cfg.home} --port ${toString cfg.port}";

    serviceConfig = {
      User = cfg.user;
      Group = cfg.group;
    };
  };
}