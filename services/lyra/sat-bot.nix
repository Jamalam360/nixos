{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types getExe;
  cfg = config.services.sat-bot;
in
{
  options.services.sat-bot = {
    enable = mkEnableOption "sat-bot";

    package = mkOption {
      type = with types; nullOr package;
      default = null;
      description = "The package to use for Sat Bot";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/sat-bot";
      description = "Working directory";
    };

    user = mkOption {
      type = types.str;
      default = "sat-bot";
      description = "User to run Sat Bot as";
    };

    group = mkOption {
      type = types.str;
      default = "sat-bot";
      description = "Group to run Sat Bot as";
    };

    settings = mkOption {
      default = {};
      description = "Settings to pass to Sat Bot";
      type = with types;
        submodule {
          freeformType = attrs;
          options = {
            discordToken = mkOption {
              type = types.str;
              default = "";
              description = "The Discord token to use for the bot";
            };

            databasePath = mkOption {
              type = types.path;
              default = "/var/lib/sat-bot/sat-bot.json";
              description = "Path to the JSON database";
            };

            guildId = mkOption {
              type = types.str;
              default = "";
              description = "The Discord guild ID to use";
            };

            n2yoKey = mkOption {
              type = types.str;
              default = "";
              description = "The N2YO API key to use";
            };
          };
        };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
    };

    users = {
      groups.sat-bot = {
        name = cfg.group;
      };

      users.sat-bot = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };

    systemd.services."sat-bot" = let
        runner = pkgs.writeShellScript "run-sat-bot" ''
          export DISCORD_TOKEN=$(cat "${cfg.settings.discordToken}");
          export DATABASE_PATH="${cfg.settings.databasePath}";
          export GUILD_ID=$(cat "${cfg.settings.guildId}");
          export N2YO_KEY=$(cat "${cfg.settings.n2yoKey}");
          ${getExe cfg.package}
        '';
      in {
      description = "Sat Bot";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        inherit (cfg) user group;

        WorkingDirectory = cfg.dataDir;
        SuccessExitStatus = 0;
        TimeoutStopSec = 10;
        Restart = "on-failure";
        RestartSec = 5;
        ExecStart = "${runner}";
      };
    };
  };
}