{
  pkgs,
  ...
}: let
  buildSystems = pkgs.writeShellScript "build-systems.sh" ''
    dir="/tmp/system-build-$(date -Iseconds)"
    git clone https://github.com/Jamalam360/nixos "$dir"
    cd "$dir"

    echo "Building Hercules"
    nixos-rebuild build --accept-flake-config --flake .#hercules
    echo "Building Leo"
    nixos-rebuild build --accept-flake-config --flake .#leo
    echo "Building Lyra"
    nixos-rebuild build --accept-flake-config --flake .#lyra
  '';
in {
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 7 * * *  root  ${buildSystems}"
    ];
  };
}