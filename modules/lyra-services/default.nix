{...}: {
  imports = [
    ./discord-github-releases.nix
    ./gitlab-runner.nix
    ./nginx.nix
    ./nix-cache.nix
    ./pinguino-quotes.nix
    ./reposilite.nix
    ./restic.nix
    ./sat-bot.nix
  ];
}
