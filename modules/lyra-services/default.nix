{...}: {
  imports = [
    ./discord-github-releases.nix
    ./gitlab-runner.nix
    ./nginx.nix
    ./nix-cache.nix
    ./reposilite.nix
    ./restic.nix
  ];
}
