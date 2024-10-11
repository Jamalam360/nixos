{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types getExe;
  cfg = config.services.pinguino-quotes;
  configFmt = pkgs.formats.yaml {};
in {
  options.services.pinguino-quotes = {
    enable = mkEnableOption "pinguino-quotes";

    package = mkOption {
      type = with types; nullOr package;
      default = null;
      description = "The package to use for Pinguino Quotes";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/pinguino-quotes";
      description = "Working directory";
    };

    user = mkOption {
      type = types.str;
      default = "pinguino-quotes";
      description = "User to run as";
    };

    group = mkOption {
      type = types.str;
      default = "pinguino-quotes";
      description = "Group to run as";
    };

    extraEnvironment = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra environment variables to pass to Pinguino Quotes";
    };

    token = mkOption {
      type = types.str;
      default = "";
      description = "Discord bot token";
    };

    settings = mkOption {
      default = {};
      description = "Settings to pass to Pinguino Quotes";
      type = types.submodule {
        freeformType = configFmt.type;
        options = {
          token = mkOption {
            type = types.str;
            default = "$DISCORD_TOKEN";
            description = "Discord bot token";
          };

          database = mkOption {
            type = types.submodule {
              freeformType = types.attrs;
              options = {
                database_path = mkOption {
                  type = types.str;
                  default = "";
                  description = "The path to the sqlite database";
                };
              };
            };
          };
        };
      };
    };
  };

  config = let
    configFile = configFmt.generate "config.yaml" cfg.settings;

    runner = pkgs.writeShellScript "run-pinguino-quotes" ''
      export DISCORD_TOKEN=$(cat "${cfg.token}");
      ${getExe cfg.package}
    '';
  in
    mkIf cfg.enable {
      environment = {
        systemPackages = [cfg.package];
      };

      users = {
        groups.pinguino-quotes = {
          name = cfg.group;
        };

        users.pinguino-quotes = {
          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
          createHome = true;
        };
      };

      systemd.services."pinguino-quotes" = {
        description = "Pinguino Quotes";
        wantedBy = ["multi-user.target"];
        environment =
          cfg.extraEnvironment
          // {
            CONFIG_PATH = "${configFile}";
          };

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
