{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types getExe;
  cfg = config.services.discord-github-releases;
in {
  options.services.discord-github-releases = {
    enable = mkEnableOption "discord-github-releases";

    package = mkOption {
      type = with types; nullOr package;
      default = null;
      description = "The package to use for Discord GitHub Releases";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/discord-github-releases";
      description = "Working directory";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall for Discord GitHub Releases";
    };

    user = mkOption {
      type = types.str;
      default = "discord-github-releases";
      description = "User to run Discord GitHub Releases as";
    };

    group = mkOption {
      type = types.str;
      default = "discord-github-releases";
      description = "Group to run Discord GitHub Releases as";
    };

    settings = mkOption {
      default = {};
      description = "Settings to pass to Discord GitHub Releases";
      type = with types;
        submodule {
          freeformType = attrs;
          options = {
            discord_webhook_urls = mkOption {
              type = types.listOf types.path;
              default = [];
              description = "A list of text file paths containing URLs of the Discord webhooks to send the message to";
            };

            port = mkOption {
              type = types.int;
              default = 8080;
              description = "The port to listen on";
            };

            message = {
              content = mkOption {
                type = types.str;
                default = "";
                description = "The content of the message";
              };

              username = mkOption {
                type = types.str;
                default = "";
                description = "The username to use for the message";
              };

              avatar_url = mkOption {
                type = types.str;
                default = "";
                description = "The URL of the avatar to use for the message";
              };

              embeds = mkOption {
                type = types.listOf (with types; attrs);
                default = [];
                description = "The embeds to include in the message";
              };
            };
          };
        };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."discord-github-releases/config.json" = mkIf (cfg.settings != {}) {
        text = builtins.toJSON cfg.settings;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      cfg.settings.port
    ];

    users = {
      groups.discord-github-releases = {
        name = cfg.group;
      };

      users.discord-github-releases = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };

    systemd.services."discord-github-releases" = let
      configLocation = "/etc/discord-github-releases/config.json";
      replaceConfigValues = pkgs.writeShellScript "replace-config-values" ''
        for webhook in ${lib.concatStringsSep " " cfg.settings.discord_webhook_urls}; do
          sed -i "s|$webhook|$(cat $webhook)|g" ${configLocation}
        done
      '';
    in {
      description = "Discord GitHub Releases";
      wantedBy = ["multi-user.target"];
      script = ''
        ${getExe cfg.package} ${configLocation}
      '';

      serviceConfig = {
        inherit (cfg) user group;

        WorkingDirectory = cfg.dataDir;
        SuccessExitStatus = 0;
        TimeoutStopSec = 10;
        Restart = "on-failure";
        RestartSec = 5;

        ExecStartPre = replaceConfigValues;
      };
    };
  };
}
