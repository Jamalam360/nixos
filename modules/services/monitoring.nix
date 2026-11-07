{
  config,
  pkgs,
  ...
}: {
  sops.secrets.discord-monitoring-webhook = {};

  systemd.services."notify-failure@" = {
    description = "Discord failure notification for %I";
    scriptArgs = "%I";
    path = [pkgs.curl pkgs.jq pkgs.systemd];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "webhook:${config.sops.secrets.discord-alerts-webhook.path}";
    };
    script = ''
      unit="$1"
      logs=$(journalctl -u "$unit" -n 15 --no-pager -o cat | tail -c 1500)
      msg=$(printf '❌ **%s** failed on **%s**\n```\n%s\n```' "$unit" "${config.networking.hostName}" "$logs")
      jq -n --arg content "$msg" '{content: $content}' |
        curl -fsS -H 'Content-Type: application/json' -d @- "$(cat "$CREDENTIALS_DIRECTORY/webhook")"
    '';
  };
}
