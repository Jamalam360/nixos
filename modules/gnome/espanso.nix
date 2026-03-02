{
  inputs,
  pkgs,
  ...
}: {
  services.espanso = {
    enable = true;
    configs = {
      default = {
        toggle_key = "RIGHT_CTRL";
      };
    };
  };

  xdg.configFile."espanso/match/misspell-en.yml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/espanso/hub/refs/heads/main/packages/misspell-en/0.1.2/package.yml";
    sha256 = "sha256-ahUdflMUr51137vIMrm5CBT5OsAbzVEwUvGjL1Izgds=";
  };

  xdg.configFile."espanso/match/misspell-en-uk.yml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/espanso/hub/refs/heads/main/packages/misspell-en-uk/0.1.2/package.yml";
    sha256 = "sha256-xGXwyL5PUwvwS3BROlUwVjVNFqoAipzV6qBF4Xbso0s=";
  };
}
