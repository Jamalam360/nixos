{...}: {
  imports = [
    ./discord-github-releases.nix
    ./monitoring.nix
    ./nginx.nix
    ./nix-cache.nix
    ./reposilite.nix
    ./restic.nix
    ./syncthing-hub.nix
  ];
}
