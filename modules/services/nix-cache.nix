{
  pkgs,
  config,
  ...
}: let
  buildSystems = pkgs.writeShellScript "build-systems.sh" ''
    set -uo pipefail

    nix-collect-garbage
    dir="/tmp/system-build-$(date -Iseconds)"
    mkdir "$dir"
    /run/current-system/sw/bin/git clone https://github.com/Jamalam360/nixos "$dir" || exit 1
    cd "$dir" || exit 1

    failed=()
    for host in hercules leo ara; do
      echo "Building $host"
      if ! /run/current-system/sw/bin/nixos-rebuild build --accept-flake-config --flake ".#$host"; then
        echo "Build failed for $host"
        failed+=("$host")
      fi
    done

    if [ ''${#failed[@]} -gt 0 ]; then
      echo "Failed builds: ''${failed[*]}"
      exit 1
    fi
  '';

  harmonia-port = "8013";
in {
  sops.secrets.nix-cache-private-key = {};

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.sops.secrets.nix-cache-private-key.path];
    settings.bind = "127.0.0.1:${harmonia-port}";
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
    onFailure = ["notify-failure@%n.service"];
    script = ''
      ${buildSystems}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
