{
  inputs,
  pkgs,
  ...
}: let
  workingDir = "/var/lib/minecraft-servers";
in {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.restic.backups.remote.paths = [
    "${workingDir}/minecraft-server/DiscordIntegration-Data"
    "${workingDir}/minecraft-server/ops.json"
    "${workingDir}/minecraft-server/whitelist.json"
    "${workingDir}/minecraft-server/audioplayer_uploads"
    "${workingDir}/minecraft-server/world"
  ];

  networking.firewall.allowedUDPPorts = [24454]; # Simple Voice Chat mod

  services.minecraft-servers = let
    modded_modpack =
      inputs.sculk.lib.fetchSculkModpack {
        inherit (pkgs) stdenvNoCC jre_headless sculk;
      } {
        url = "https://raw.githubusercontent.com/Jamalam360/pack/75844eefc810b37e13d4a3fa99a60e6114410aef";
        hash = "sha256-EANixnhaR35y5FK9OVY5dt3auFLki/1lWAyjem7SLFE=";
      };
    vanilla_modpack =
      inputs.sculk.lib.fetchSculkModpack {
        inherit (pkgs) stdenvNoCC jre_headless sculk;
      } {
        url = "https://raw.githubusercontent.com/Jamalam360/vanilla-server/88e198103812722496c9719e0851f9b4f48821a6";
        hash = "sha256-KJsx+U0OACKxOqd/p+181PlA2JZcVc3si+8UesbUPwQ=";
      };

    # inspo: https://github.com/Infinidoge/nix-minecraft/pull/43
    collectFiles = let
      inherit (pkgs) lib;
      mapListToAttrs = fn: fv: list:
        lib.listToAttrs (map (x: lib.nameValuePair (fn x) (fv x)) list);
    in
      path: prefix:
        mapListToAttrs
        (x: builtins.unsafeDiscardStringContext (lib.removePrefix "${path}/" x))
        lib.id (lib.filesystem.listFilesRecursive "${path}/${prefix}");
  in {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = workingDir;

    servers.minecraft-server = {
      enable = false;
      package = pkgs.minecraftServers.fabric-1_20_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        mods = "${modded_modpack}/mods";
        config = "${modded_modpack}/config";
      };
      files =
        collectFiles "${modded_modpack}" "config"
        // {
          "config/Discord-Integration.toml" = "/var/lib/Discord-Integration.toml";
        };
      serverProperties = {
        server-port = 25565;
        white-list = true;
        level-seed = 5716240849493836707;
        view-distance = 20;
        difficulty = "hard";
      };
      jvmOpts = "-Xmx6G -Xms6G";
    };

    servers.vanilla-server = {
      enable = true;
      package = pkgs.minecraftServers.fabric-1_21_1;
      autoStart = true;
      restart = "always";
      symlinks = {
        mods = "${vanilla_modpack}/mods";
      };
      files = collectFiles "${vanilla_modpack}" "config";
      serverProperties = {
        server-port = 25566;
        white-list = true;
        view-distance = 20;
        difficulty = "hard";
      };
      jvmOpts = "-Xmx4G -Xms4G";
    };
  };

  systemd.timers."restart-minecraft" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Unit = "restart-minecraft.service";
    };
  };

  systemd.services."restart-minecraft" = {
    script = ''
      set -eu
      systemctl restart minecraft-server-minecraft-server.service
      systemctl restart minecraft-server-vanilla-server.service
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
