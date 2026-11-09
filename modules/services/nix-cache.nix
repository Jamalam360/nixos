{
  pkgs,
  config,
  ...
}: let
  buildSystems = pkgs.writeShellScript "build-systems.sh" ''
    set -uo pipefail
    rev="$1"

    rm -rf /tmp/system-build-*
    dir="/tmp/system-build-$rev"
    git clone https://github.com/Jamalam360/nixos "$dir" || exit 1
    cd "$dir" && git checkout "$rev" || exit 1
    
    failed=()
    for host in hercules leo ara; do
      echo "Building $host"
      if ! nix build --accept-flake-config ".#nixosConfigurations.$host.config.system.build.toplevel" --out-link "result-$host"; then
        echo "Build failed for $host"
        failed+=("$host")
      fi
    done

    if [ ''${#failed[@]} -gt 0 ]; then
      echo "Failed builds at $rev: ''${failed[*]}"
      exit 1
    fi

    nix-store --gc
  '';

  harmonia-port = "8013";
in {
  sops.secrets = {
    discord-monitoring-webhook = {};
    nix-cache-private-key = {};
  };

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

  systemd.services.nix-builder = {
    onFailure = ["notify-failure@%n.service"];
    path = [pkgs.git pkgs.nixos-rebuild pkgs.nix];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "nix-builder";
      LoadCredential = "webhook:${config.sops.secrets.discord-monitoring-webhook.path}";
    };
    script = ''
      state=/var/lib/nix-builder/last-rev
      rev=$(git ls-remote https://github.com/Jamalam360/nixos refs/heads/main | cut -f1)
      [ -n "$rev" ] || { echo "Couldn't read main"; exit 1; }

      if [ "$rev" = "$(cat "$state" 2>/dev/null)" ]; then
        echo "main unchanged at $rev, nothing to build"
        exit 0
      fi

      echo "$rev" > "$state"
      ${buildSystems} "$rev"

      if [ $? -eq 0 ]; then
        jq -n --arg content "✅ **Cache built** for $rev on **${config.networking.hostName}**" '{content: $content}' |
          curl -fsS -H 'Content-Type: application/json' -d @- "$(cat "$CREDENTIALS_DIRECTORY/webhook")"
      fi
    '';
  };

  systemd.timers.nix-builder = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:0/15";
      Persistent = true;
    };
  };
}
