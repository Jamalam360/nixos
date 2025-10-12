{...}: {
  imports = [
    ./discord-github-releases.nix
    ./nginx.nix
    ./nix-cache.nix
    ./reposilite.nix
    ./restic.nix
  ];
}
