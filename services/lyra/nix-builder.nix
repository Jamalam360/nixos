{
  pkgs,
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
    /run/current-system/sw/bin/nixos-rebuild --accept-flake-config --flake .#leo
    echo "Building Lyra"
    /run/current-system/sw/bin/nixos-rebuild --accept-flake-config --flake .#lyra
  '';
in {
  systemd.timers."nix-builder" = {
    wantedBy = [ "timers.target" ];
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