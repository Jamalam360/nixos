final: prev: {
  custom = {
    discord-github-releases = prev.callPackage ./discord-github-releases.nix {};
  };
}
