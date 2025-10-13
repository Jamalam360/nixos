{
  pkgs,
  config,
  ...
}: let
  buildSystems = pkgs.writeShellScript "build-systems.sh" ''
    dir="/tmp/system-build-$(date -Iseconds)"
    mkdir dir
    /run/current-system/sw/bin/git clone https://github.com/Jamalam360/nixos "$dir"
    cd "$dir"

    echo "Building Hercules"
    /run/current-system/sw/bin/nixos-rebuild build --accept-flake-config --flake .#hercules
    echo "Building Leo"
    /run/current-system/sw/bin/nixos-rebuild build --accept-flake-config --flake .#leo
    echo "Building Ara"
    /run/current-system/sw/bin/nixos-rebuild build --accept-flake-config --flake .#ara
  '';

  harmonia-port = "8013";
in {
  sops.secrets.nix-cache-private-key.neededForUsers = true;

  # services.nix-serve = {
  #   enable = true;
  #   secretKeyFile = config.sops.secrets.nix-cache-private-key.path;
  # };

  # services.nginx.virtualHosts."nixcache.jamalam.tech" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
  # };

  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.sops.secrets.nix-cache-private-key.path ];
    settings.bind = "[::]:${harmonia-port}";
  };

  services.nginx.virtualHosts."nixcache.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;

    locations."/".extraConfig = ''
      proxy_pass http://127.0.0.1:${harmonia-port};
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
  };

  systemd.timers."nix-builder" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "07:00";
      Persistent = true;
      Unit = "nix-builder.service";
    };
  };

  systemd.services."nix-builder" = {
    script = ''
      ${buildSystems}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
